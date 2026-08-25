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

/// Shared "AI Smart Entry" quick-entry capability: a free-text field with
/// mic dictation and receipt-photo scan, parsed locally then always
/// escalated to Gemini (see [ParseQuickEntryUseCase]) behind a consent +
/// daily-cap gate.
///
/// Hosts must `extend TransactionFormController`, provide
/// [quickEntryCategoryType], and expose their own `categoryKey`/
/// [pendingPrefillCategoryId]. Call [initQuickEntry]/[disposeQuickEntry]/
/// [resetQuickEntry] from the host's own `onInit`/`onClose`/`onReset` — not
/// automatic, to avoid relying on mixin `super` linearization order.
mixin QuickEntryMixin on TransactionFormController {
  /// Category type quick-entry searches/prefills within.
  String get quickEntryCategoryType;

  /// Further restricts [quickEntryCategoryType] to these `groupId`s (e.g.
  /// Loan only offers the currently-selected direction's group). Null means
  /// every enabled category of that type.
  List<String>? get quickEntryCategoryGroupIds => null;

  /// Bumped to force the category picker to remount and resolve
  /// [pendingPrefillCategoryId] as its initial selection.
  RxInt get categoryKey;

  /// Set right before [categoryKey] is bumped so the remounted category
  /// picker resolves this id (same mechanism edit-mode uses).
  Rx<String?> get pendingPrefillCategoryId;

  final TextEditingController quickEntryController = TextEditingController();
  final Rx<QuickEntryParseResult?> quickEntrySuggestion =
      Rx<QuickEntryParseResult?>(null);
  final RxBool isParsingQuickEntry = false.obs;
  final RxBool isListeningQuickEntry = false.obs;

  /// Locale key for an inline status message; null means nothing to show.
  final Rx<String?> quickEntryErrorKey = Rx<String?>(null);

  List<CategoryEntity> _quickEntryCategories = [];
  Timer? _quickEntryDebounce;
  bool _quickEntryDisposed = false;

  /// Bumped by [resetQuickEntry] to invalidate any submission still in
  /// flight, so a stale cloud response can't overwrite a newer entry.
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
    // Only stop it if this instance holds it — the recognizer is a global singleton.
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

  /// Reloads the category cache used to label a resolved `categoryId`. Must
  /// be re-called whenever [quickEntryCategoryGroupIds] changes at runtime
  /// (e.g. Loan switching direction), or the label lookup goes stale.
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

  /// False for Investment, where [applyQuickEntryCategory] is a no-op — a
  /// resolved category would otherwise look tappable when it silently isn't.
  bool get quickEntryShowsCategoryInLabel => true;

  /// Display label for a suggestion, e.g. "50.00k · Cà phê · 12/08" — lists
  /// only whatever actually resolved.
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

  /// One submission's generation token: `isCurrent` reports whether
  /// [resetQuickEntry] has since invalidated it; `resetIfCurrent` clears
  /// [isParsingQuickEntry] only if it's still the active one.
  (bool Function(), VoidCallback) _trackGeneration() {
    final generation = _quickEntryGeneration;
    bool isCurrent() =>
        !_quickEntryDisposed && generation == _quickEntryGeneration;
    void resetIfCurrent() {
      if (isCurrent()) isParsingQuickEntry.value = false;
    }
    return (isCurrent, resetIfCurrent);
  }

  /// Consent-then-daily-cap gate shared by every cloud escalation path.
  /// Returns false — with [quickEntryErrorKey] already set — on declined
  /// consent, an exhausted cap, or a stale generation; callers must return
  /// immediately without touching [quickEntryErrorKey] themselves in that
  /// case, or they'll clobber the specific message just set here.
  Future<bool> _passCloudGate({
    required BuildContext context,
    required bool Function() isCurrentGeneration,
    required VoidCallback resetParsingIfCurrent,
  }) async {
    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (!await prefs.isConsentGiven()) {
      final agreed = await _promptCloudConsent(context);
      if (!isCurrentGeneration()) return false;
      if (!agreed) {
        resetParsingIfCurrent();
        quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
        return false;
      }
      await prefs.setConsentGiven(true);
    }

    if (!await prefs.tryConsumeDailyCall()) {
      if (!isCurrentGeneration()) return false;
      resetParsingIfCurrent();
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_daily_limit_reached;
      return false;
    }

    return true;
  }

  /// Explicit "done" trigger (submit / finished voice dictation) — the only
  /// path that calls Gemini, so a network call never fires while someone
  /// is still mid-typing.
  Future<void> submitQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    // Guards a fast double-submit from firing two concurrent cloud calls.
    if (isParsingQuickEntry.value) return;
    final text = quickEntryController.text.trim();
    if (text.isEmpty) return;

    _quickEntryDebounce?.cancel();
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    final (isCurrentGeneration, resetParsingIfCurrent) = _trackGeneration();

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(
      text,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (!isCurrentGeneration()) return;

    if (!await _passCloudGate(
      context: context,
      isCurrentGeneration: isCurrentGeneration,
      resetParsingIfCurrent: resetParsingIfCurrent,
    )) {
      return;
    }

    final cloudResult = await parseUseCase.parseWithCloud(
      text: text,
      localResult: local,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    resetParsingIfCurrent();
    // The field stays editable during the round trip — re-check the text
    // still matches what was sent before applying/erroring on anything.
    if (!isCurrentGeneration() || text != quickEntryController.text.trim()) {
      return;
    }

    // Cloud failing outright (offline, API disabled) shouldn't throw away a
    // local result that was already good enough to be worth escalating.
    final suggestion = (cloudResult != null && !cloudResult.isEmpty)
        ? cloudResult
        : local;
    if (suggestion.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = suggestion;
  }

  /// Reentrancy gate for receipt-photo entry — call before showing the
  /// source-picker sheet (not after) so the lock covers that whole round
  /// trip, then follow with [submitQuickEntryFromImage] or
  /// [cancelQuickEntryImage].
  bool beginQuickEntryImage() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return false;
    }
    if (isParsingQuickEntry.value) return false;
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    return true;
  }

  /// Releases the lock [beginQuickEntryImage] took when the user dismissed
  /// the sheet without picking anything.
  void cancelQuickEntryImage() {
    isParsingQuickEntry.value = false;
  }

  /// Picks an image, runs on-device OCR, then feeds the result through the
  /// same local-parse/cloud-fallback pipeline as [submitQuickEntry] — the
  /// cloud leg sends the image itself, not the OCR text, since receipt
  /// print is often too small/faded for OCR to be a trustworthy sole input.
  /// Assumes the caller already holds the lock via [beginQuickEntryImage].
  Future<void> submitQuickEntryFromImage(
    BuildContext context, {
    required bool fromCamera,
  }) async {
    final (isCurrentGeneration, resetParsingIfCurrent) = _trackGeneration();

    final pickResult = await CcReceiptScanHelper.pickReceiptImage(
      fromCamera: fromCamera,
    );
    if (!isCurrentGeneration()) return;
    final picked = pickResult.image;
    if (picked == null) {
      resetParsingIfCurrent();
      // A denied permission gets explicit feedback; a plain cancel stays silent.
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

    if (!await _passCloudGate(
      context: context,
      isCurrentGeneration: isCurrentGeneration,
      resetParsingIfCurrent: resetParsingIfCurrent,
    )) {
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

    // Cloud failing outright shouldn't throw away a local (OCR-text) result
    // that was already good enough to be worth escalating.
    final suggestion = (cloudResult != null && !cloudResult.isEmpty)
        ? cloudResult
        : local;
    if (suggestion.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = suggestion;
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
      // The recognizer can stop itself (e.g. a silence timeout) without a
      // final result — reset here too, or the mic icon stays stuck "listening".
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

  /// Applies a resolved `categoryId` to the category-picker UI. Investment
  /// overrides this as a no-op — its category always comes from the chosen
  /// asset, a manual pick by design.
  void applyQuickEntryCategory(String categoryId) {
    pendingPrefillCategoryId.value = categoryId;
    categoryKey.value++;
  }

  /// Pre-fills whichever fields [result] resolved; a null field is left at
  /// the form's existing default for the user to fill in by hand.
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
