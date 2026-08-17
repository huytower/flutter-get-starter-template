import 'dart:async';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/usecases/parse_quick_entry_usecase.dart';
import '../widgets/cloud_consent_sheet.dart';
import 'transaction_form_controller.dart';

/// Shared "AI Smart Entry" quick-entry capability — a free-text field
/// ("50k cafe") with mic dictation and a receipt-photo scan, parsed locally
/// first (see [ParseQuickEntryUseCase]) with a consent-gated, daily-capped
/// cloud fallback for whatever the local parse couldn't determine. Applied
/// via [applyQuickEntryParse] using the same "prefill, user still confirms"
/// contract as Expense's merchant/location match. Originally
/// Expense-only (Phase 3.6/3.7); factored out here so Income/Investment/
/// Loan can offer the same entry point without duplicating ~200 lines each.
///
/// Hosts must `extend TransactionFormController` (for `amountStr`,
/// `noteController`, `date`/`setDate`, `hideKeypad`), provide
/// [quickEntryCategoryType], and expose their own `categoryKey`/
/// `pendingPrefillCategoryId` — every form already declares `categoryKey`
/// for its own category picker; `pendingPrefillCategoryId` is new (see
/// [applyQuickEntryCategory]'s doc for why Investment needs neither).
/// Hosts must call [initQuickEntry]/[disposeQuickEntry]/[resetQuickEntry]
/// from their own `onInit`/`onClose`/`onReset` — not done automatically, to
/// avoid relying on mixin `super.onInit()` linearization order when the
/// host also overrides those hooks.
mixin QuickEntryMixin on TransactionFormController {
  /// Which category type quick-entry should search/prefill within (e.g.
  /// [CategoryType.income] for the income form).
  String get quickEntryCategoryType;

  /// Further restricts [quickEntryCategoryType]'s categories to these
  /// `groupId`s, same contract as `CategorySelectionSection.groupIds` — e.g.
  /// the Loan form only offers the currently-selected direction's group.
  /// Null (the default) leaves every enabled category of that type
  /// unfiltered.
  List<String>? get quickEntryCategoryGroupIds => null;

  /// Bumped to force a `CategorySelectionSection`-driven category picker to
  /// remount and resolve [pendingPrefillCategoryId] as its initial
  /// selection — every host already declares this for its own category UI.
  RxInt get categoryKey;

  /// Set right before [categoryKey] is bumped, so the remounted category
  /// picker resolves and reports back the real `CategoryEntity` for this id
  /// (same mechanism edit-mode uses via `editingTransaction?.categoryId`).
  Rx<String?> get pendingPrefillCategoryId;

  final TextEditingController quickEntryController = TextEditingController();
  final Rx<QuickEntryParseResult?> quickEntrySuggestion =
      Rx<QuickEntryParseResult?>(null);
  final RxBool isParsingQuickEntry = false.obs;
  final RxBool isListeningQuickEntry = false.obs;

  /// Locale key for an inline status message (e.g. "couldn't understand" /
  /// "daily AI limit reached") — null means no message to show.
  final Rx<String?> quickEntryErrorKey = Rx<String?>(null);

  List<CategoryEntity> _quickEntryCategories = [];
  Timer? _quickEntryDebounce;
  bool _quickEntryDisposed = false;

  /// Bumped by [resetQuickEntry] to invalidate any quick-entry submission
  /// still in flight (e.g. an abandoned cloud call from a transaction the
  /// user already saved and moved on from) — a stale submission recognizes
  /// it's no longer the current generation and skips touching
  /// [isParsingQuickEntry] itself, letting reset reclaim that flag
  /// immediately for the next entry.
  int _quickEntryGeneration = 0;

  /// Call from the host's `onInit`.
  void initQuickEntry() {
    quickEntryController.addListener(_onQuickEntryTextChanged);
    refreshQuickEntryCategories();
  }

  /// Call from the host's `onClose`.
  void disposeQuickEntry() {
    _quickEntryDisposed = true;
    _quickEntryDebounce?.cancel();
    quickEntryController
      ..removeListener(_onQuickEntryTextChanged)
      ..dispose();
    // Only stop the (global, singleton) recognizer if this instance is the
    // one actually holding it.
    if (isListeningQuickEntry.value) {
      CcSpeechHelper.stopListening();
    }
  }

  /// Call from the host's `onReset`.
  void resetQuickEntry() {
    pendingPrefillCategoryId.value = null;
    quickEntrySuggestion.value = null;
    quickEntryErrorKey.value = null;
    quickEntryController.clear();
    _quickEntryGeneration++;
    isParsingQuickEntry.value = false;
  }

  /// Reloads the category cache [quickEntryResultLabel] uses to look up a
  /// display label for a resolved `categoryId`. Called once from
  /// [initQuickEntry] — hosts whose [quickEntryCategoryGroupIds] can change
  /// at runtime (e.g. Loan switching Đi vay/Cho vay direction) must call
  /// this again whenever that happens, or the label lookup keeps searching
  /// the now-stale group and silently drops the category from the label.
  Future<void> refreshQuickEntryCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    final groupIds = quickEntryCategoryGroupIds;
    _quickEntryCategories =
        result
            .tryGetSuccess()
            ?.where(
              (c) =>
                  c.isEnabled &&
                  c.type == quickEntryCategoryType &&
                  (groupIds == null || groupIds.contains(c.groupId)),
            )
            .toList() ??
        [];
  }

  CategoryEntity? _findQuickEntryCategory(String id) {
    for (final c in _quickEntryCategories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Whether a resolved `categoryId` should be shown in
  /// [quickEntryResultLabel] at all. True by default; Investment overrides
  /// this to false since [applyQuickEntryCategory] is a no-op there — a
  /// category resolved by Gemini would otherwise appear in the suggestion
  /// chip text as if tapping "Apply" will select it, when it silently won't.
  bool get quickEntryShowsCategoryInLabel => true;

  /// Display label for a quick-entry suggestion, e.g. "50.00k · Cà phê ·
  /// 12/08". Not every field is guaranteed to be resolved (a failed field
  /// is just null), so this only lists whatever actually came back instead
  /// of assuming amount/category are always present.
  String quickEntryResultLabel(QuickEntryParseResult result) {
    final parts = <String>[];
    if (result.amount != null) {
      parts.add('${formatVndShort(result.amount!)}đ');
    }
    if (result.categoryId != null && quickEntryShowsCategoryInLabel) {
      final category = _findQuickEntryCategory(result.categoryId!);
      if (category != null) parts.add(el.tr(category.nameKey));
    }
    if (result.date != null) {
      parts.add(el.DateFormat('dd/MM').format(result.date!));
    }
    if (parts.isEmpty && result.note != null) {
      parts.add(result.note!);
    }
    return parts.join(' · ');
  }

  void _onQuickEntryTextChanged() {
    quickEntryErrorKey.value = null;
    _quickEntryDebounce?.cancel();
    _quickEntryDebounce = Timer(
      const Duration(milliseconds: 400),
      _runLocalQuickEntryParse,
    );
  }

  Future<void> _runLocalQuickEntryParse() async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    final text = quickEntryController.text.trim();
    if (text.isEmpty) {
      quickEntrySuggestion.value = null;
      return;
    }
    final local = await getIt<ParseQuickEntryUseCase>().parseLocally(
      text,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (_quickEntryDisposed || text != quickEntryController.text.trim()) {
      return;
    }
    quickEntrySuggestion.value = local.isComplete ? local : null;
  }

  /// Explicit "done" trigger (text field submit, or a finished voice
  /// dictation) — unlike the as-you-type local-only debounce above, this is
  /// the sole path that may escalate to the consent-gated, daily-capped
  /// cloud fallback, so a network call only ever fires on a deliberate user
  /// action, never silently while someone is still mid-typing.
  Future<void> submitQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    // Reentrancy guard: without this, a fast double-submit (double-tap
    // Enter while the first call is still awaiting the cloud round trip, or
    // voice auto-submit racing a manual submit) would fire two concurrent
    // cloud calls and desync `quickEntrySuggestion` between them.
    if (isParsingQuickEntry.value) return;
    final text = quickEntryController.text.trim();
    if (text.isEmpty) return;

    _quickEntryDebounce?.cancel();
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    // Captured once at the start of this specific submission — see
    // _quickEntryGeneration's doc.
    final generation = _quickEntryGeneration;
    bool isCurrentGeneration() =>
        !_quickEntryDisposed && generation == _quickEntryGeneration;
    void resetParsingIfCurrent() {
      if (isCurrentGeneration()) isParsingQuickEntry.value = false;
    }

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(
      text,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (!isCurrentGeneration()) return;

    if (local.isComplete) {
      resetParsingIfCurrent();
      quickEntrySuggestion.value = local;
      return;
    }

    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (!await prefs.isConsentGiven()) {
      final agreed = await _promptCloudConsent(context);
      if (!isCurrentGeneration()) return;
      if (!agreed) {
        resetParsingIfCurrent();
        quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
        return;
      }
      await prefs.setConsentGiven(true);
    }

    // Atomically checks-and-reserves a slot under the daily cap — see
    // AiFallbackPreferenceDataSource.tryConsumeDailyCall's doc for why a
    // separate isUnderDailyLimit()+incrementTodayFallbackCount() pair would
    // be a check-then-act race across concurrent callers.
    if (!await prefs.tryConsumeDailyCall()) {
      if (!isCurrentGeneration()) return;
      resetParsingIfCurrent();
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_daily_limit_reached;
      return;
    }

    final cloudResult = await parseUseCase.parseWithCloud(
      text: text,
      localResult: local,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    resetParsingIfCurrent();
    // The text field stays editable throughout this round trip — re-check
    // the text still matches what was actually sent before applying
    // anything, same as the local-parse leg already does.
    if (!isCurrentGeneration() || text != quickEntryController.text.trim()) {
      return;
    }

    // A partial result (e.g. only the category resolved, or only a date)
    // still gets surfaced — whichever fields failed just stay null and are
    // left for the user to fill in by hand; only a totally empty result
    // counts as "couldn't understand".
    if (cloudResult == null || cloudResult.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = cloudResult;
  }

  /// Reentrancy gate for receipt-photo entry. Must be called (and, on
  /// success, followed by either [submitQuickEntryFromImage] or
  /// [cancelQuickEntryImage]) *before* showing the take-photo/choose-gallery
  /// sheet — not after it resolves — so the lock covers that whole UI round
  /// trip, not just the OCR/cloud portion. [submitQuickEntry] closes the
  /// equivalent window for free by checking-then-setting [isParsingQuickEntry]
  /// with no `await` in between; the photo path needs an explicit method to
  /// get the same property since a whole sheet interaction sits between "user
  /// tapped scan" and "we know which image to process."
  bool beginQuickEntryImage() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return false;
    }
    if (isParsingQuickEntry.value) return false;
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    return true;
  }

  /// Releases the lock [beginQuickEntryImage] took, for when the user
  /// dismissed the source-selection sheet without picking anything.
  void cancelQuickEntryImage() {
    isParsingQuickEntry.value = false;
  }

  /// Picks an image (camera or gallery), runs on-device OCR, then feeds the
  /// recognized text through the exact same local-parse/cloud-fallback
  /// pipeline [submitQuickEntry] uses, landing in the same
  /// [quickEntrySuggestion] so the UI needs no separate suggestion state or
  /// chip. The cloud leg sends the image itself (see
  /// [ParseQuickEntryUseCase.parseImageWithCloud]), not the OCR text, since
  /// receipt print is small/faded enough that OCR often can't be trusted as
  /// the sole cloud input.
  ///
  /// Assumes the caller already holds the [isParsingQuickEntry] lock via a
  /// successful [beginQuickEntryImage] call.
  Future<void> submitQuickEntryFromImage(
    BuildContext context, {
    required bool fromCamera,
  }) async {
    final generation = _quickEntryGeneration;
    bool isCurrentGeneration() =>
        !_quickEntryDisposed && generation == _quickEntryGeneration;
    void resetParsingIfCurrent() {
      if (isCurrentGeneration()) isParsingQuickEntry.value = false;
    }

    final pickResult = await CcReceiptScanHelper.pickReceiptImage(
      fromCamera: fromCamera,
    );
    if (!isCurrentGeneration()) return;
    final picked = pickResult.image;
    if (picked == null) {
      resetParsingIfCurrent();
      // A denied permission gets explicit feedback (with a path to fix it
      // via Settings); a plain cancel/unreadable-file stays silent, same as
      // every other quick-entry failure mode.
      if (pickResult.permissionDenied) {
        quickEntryErrorKey.value =
            CcLocaleKeys.quick_entry_photo_permission_denied;
      }
      return;
    }

    final ocrText = await CcReceiptScanHelper.recognizeText(picked.path);
    if (!isCurrentGeneration()) return;

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(
      ocrText,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (!isCurrentGeneration()) return;

    if (local.isComplete) {
      resetParsingIfCurrent();
      quickEntrySuggestion.value = local;
      return;
    }

    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (!await prefs.isConsentGiven()) {
      final agreed = await _promptCloudConsent(context);
      if (!isCurrentGeneration()) return;
      if (!agreed) {
        resetParsingIfCurrent();
        quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
        return;
      }
      await prefs.setConsentGiven(true);
    }

    if (!await prefs.tryConsumeDailyCall()) {
      if (!isCurrentGeneration()) return;
      resetParsingIfCurrent();
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_daily_limit_reached;
      return;
    }

    final cloudResult = await parseUseCase.parseImageWithCloud(
      imageBytes: picked.bytes,
      mimeType: picked.mimeType,
      localResult: local,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    // Same partial-result tolerance as submitQuickEntry — e.g. amount+
    // category readable but the date printed too faint to OCR still counts
    // as a usable suggestion.
    if (cloudResult == null || cloudResult.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = cloudResult;
  }

  Future<bool> _promptCloudConsent(BuildContext context) async {
    final result = await CloudConsentSheet.show(context);
    return result ?? false;
  }

  Future<void> toggleVoiceQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    if (isListeningQuickEntry.value) {
      await CcSpeechHelper.stopListening();
      isListeningQuickEntry.value = false;
      return;
    }

    hideKeypad();
    quickEntryErrorKey.value = null;
    isListeningQuickEntry.value = true;
    final started = await CcSpeechHelper.startListening(
      onResult: (recognizedWords, isFinal) {
        if (_quickEntryDisposed) return;
        quickEntryController.text = recognizedWords;
        quickEntryController.selection = TextSelection.collapsed(
          offset: recognizedWords.length,
        );
        if (isFinal) {
          isListeningQuickEntry.value = false;
          submitQuickEntry(context);
        }
      },
      // The recognizer can stop itself (e.g. a silence timeout) without
      // ever delivering a final result — without this, isListeningQuickEntry
      // would never reset in that case and the mic icon would stay showing
      // "actively listening" until the user taps it again.
      onListeningStopped: () {
        if (_quickEntryDisposed) return;
        isListeningQuickEntry.value = false;
      },
    );
    if (_quickEntryDisposed) return;
    if (!started) {
      isListeningQuickEntry.value = false;
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_mic_permission_denied;
    }
  }

  /// Applies a resolved `categoryId` to this form's category-selection UI —
  /// the default `pendingPrefillCategoryId`/[categoryKey] remount pattern
  /// used by every `CategorySelectionSection`-based form (Expense/Income/
  /// Loan). Investment overrides this as a no-op: it has no category-picker
  /// UI of its own — category is derived from the chosen investment asset,
  /// which stays a manual pick by design (see the Investment section of the
  /// AI Smart Entry rollout discussion).
  void applyQuickEntryCategory(String categoryId) {
    pendingPrefillCategoryId.value = categoryId;
    categoryKey.value++;
  }

  /// Pre-fills whichever fields [result] actually resolved — same "prefill,
  /// user still confirms" contract as Expense's merchant/location match. A
  /// field that failed to parse (null) is simply left untouched, i.e. at
  /// whatever default the form already had (today's date, empty note), for
  /// the user to fill in manually rather than blocking the rest.
  void applyQuickEntryParse(QuickEntryParseResult result) {
    if (result.amount != null) amountStr.value = result.amount!.toString();
    if (result.categoryId != null) {
      applyQuickEntryCategory(result.categoryId!);
    }
    if (result.date != null) setDate(result.date!);
    if (result.note != null) noteController.text = result.note!;
    quickEntrySuggestion.value = null;
    quickEntryController.clear();
  }

  void dismissQuickEntrySuggestion() {
    quickEntrySuggestion.value = null;
  }
}
