import 'dart:async';
import 'dart:ui';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/ai_fallback_preference_datasource.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../../core/helper/quick_entry_intent.dart';
import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../liability/domain/entities/liability_entity.dart';
import '../../../profile/user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/smart_entry_input.dart';
import '../../domain/usecases/parse_quick_entry_usecase.dart';
import '../../domain/usecases/parse_smart_entry_usecase.dart';
import '../widgets/smart_entry_preview_sheet.dart';
import 'quick_entry_auto_save_helper.dart';
import 'smart_entry_preview_state.dart';
import 'transaction_controller.dart';
import 'transaction_form_controller.dart';

typedef QuickEntryCloudResult = ({
  List<ParsedTransactionEntity> rows,
  String? errorKey,
});

/// Shared "AI Smart Entry" quick-entry capability: a free-text field with
/// mic dictation and receipt-photo scan, parsed locally then always
/// escalated to Gemini (see [ParseSmartEntryUseCase], which enforces the
/// daily cap).
///
/// Hosts must `extend TransactionFormController`, provide
/// [quickEntryCategoryType], and expose their own `categoryKey`/
/// [pendingPrefillCategoryId]. Call [initQuickEntry]/[disposeQuickEntry]/
/// [resetQuickEntry] from the host's own `onInit`/`onClose`/`onReset` — not
/// automatic, to avoid relying on mixin `super` linearization order.
mixin QuickEntryMixin on TransactionFormController
    implements WidgetsBindingObserver {
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
  final Rx<ParsedTransactionEntity?> quickEntrySuggestion =
      Rx<ParsedTransactionEntity?>(null);
  final RxBool isParsingQuickEntry = false.obs;
  final RxBool isListeningQuickEntry = false.obs;

  final QuickEntryAutoSaveHelper _autoSaveHelper = QuickEntryAutoSaveHelper();

  /// Remaining seconds until auto-save triggers. VIP only.
  RxInt get autoSaveCountdown => _autoSaveHelper.autoSaveCountdown;
  final RxBool isVip = false.obs;

  /// Locale key for an inline status message; null means nothing to show.
  final Rx<String?> quickEntryErrorKey = Rx<String?>(null);

  List<CategoryEntity> _quickEntryCategories = [];
  Timer? _quickEntryDebounce;
  bool _quickEntryDisposed = false;

  bool get isQuickEntryDisposed => _quickEntryDisposed;

  /// Bumped by [resetQuickEntry] to invalidate any submission still in
  /// flight, so a stale cloud response can't overwrite a newer entry.
  int _quickEntryGeneration = 0;

  /// Call from the host's `onInit`.
  void initQuickEntry() {
    WidgetsBinding.instance.addObserver(this);
    quickEntryController.addListener(_onQuickEntryTextChanged);
    refreshQuickEntryCategories();
  }

  /// Call from the host's `onClose`.
  void disposeQuickEntry() {
    WidgetsBinding.instance.removeObserver(this);
    _quickEntryDisposed = true;
    _quickEntryDebounce?.cancel();
    _cancelAutoSave();
    quickEntryController
      ..removeListener(_onQuickEntryTextChanged)
      ..dispose();
    // Only stop it if this instance holds it — the recognizer is a global singleton.
    if (isListeningQuickEntry.value) {
      CcSpeechHelper.stopListening();
    }
  }

  @override
  void hideKeypad() => super.hideKeypad();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _cancelAutoSave();
    }
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didChangeViewFocus(ViewFocusEvent event) {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<AppExitResponse> didRequestAppExit() async => AppExitResponse.exit;

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) => false;

  @override
  void handleStatusBarTap() {}

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {}

  @override
  Future<bool> didPopRoute() => Future.value(false);

  @override
  Future<bool> didPushRoute(String route) => Future.value(false);

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) =>
      Future.value(false);

  /// Bumps the generation to invalidate any in-flight cloud call.
  void resetQuickEntry() {
    _cancelAutoSave();
    pendingPrefillCategoryId.value = null;
    quickEntrySuggestion.value = null;
    quickEntryErrorKey.value = null;
    quickEntryController.clear();
    _quickEntryGeneration++;
    isParsingQuickEntry.value = false;
  }

  void _cancelAutoSave() {
    _autoSaveHelper.cancelAutoSave();
  }

  @protected
  void cancelAutoSaveCountdown() => _cancelAutoSave();

  void cancelAutoSaveManually() {
    _cancelAutoSave();
    // Also clear the suggestion so it doesn't linger after a manual cancel
    quickEntrySuggestion.value = null;
  }

  Future<void> startAutoSaveTimer(BuildContext context) async {
    _autoSaveHelper.startAutoSaveTimer(
      context: context,
      hasSelectableCategory: quickEntryHasSelectableCategory,
      onSave: () {
        final suggestion = quickEntrySuggestion.value;
        if (suggestion != null) {
          applyQuickEntryParse(suggestion);
          submitForm(context);
        }
      },
    );
  }

  @protected
  void startAutoSaveCountdown(VoidCallback onElapsed) {
    _autoSaveHelper.startAutoSaveCountdown(onElapsed);
  }

  /// Direction string (e.g. 'borrow'/'lend') for dual-direction forms like
  /// Liability. Used by the cross-tab intent switcher to decide if a
  /// switch is needed even within the same tab kind.
  String get quickEntryDirection => '';

  /// Optional hook for controllers to apply custom state based on the
  /// detected intent and raw text (e.g. setting direction to 'contribute'
  /// in Investment).
  void applyQuickEntryIntent(QuickEntryIntent intent, String text) {}

  /// Reloads the category cache used to label a resolved `categoryId`. Must
  /// be re-called whenever [quickEntryCategoryGroupIds] changes at runtime
  /// (e.g. Loan switching direction), or the label lookup goes stale.
  Future<void> refreshQuickEntryCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    final groupIds = quickEntryCategoryGroupIds;
    final list =
        result
            .tryGetSuccess()
            ?.where(
              (category) =>
                  category.isEnabled &&
                  category.type == quickEntryCategoryType &&
                  (groupIds == null || groupIds.contains(category.groupId)),
            )
            .toList() ??
        [];
    _quickEntryCategories = list;
  }

  @protected
  CategoryEntity? findQuickEntryCategory(String id) {
    for (final category in _quickEntryCategories) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// False for Investment, where [applyQuickEntryCategory] is a no-op — a
  /// resolved category would otherwise look tappable when it silently isn't.
  bool get quickEntryShowsCategoryInLabel => true;

  /// Display label for a suggestion, e.g. "50.00k · Cà phê · 12/08" — lists
  /// only whatever actually resolved.
  String quickEntryResultLabel(ParsedTransactionEntity result) {
    final parts = <String>[];
    if (result.amount != null) {
      parts.add(formatShortCurrencyWithSymbol(result.amount!));
    }
    if (result.categoryId != null && quickEntryShowsCategoryInLabel) {
      final category = findQuickEntryCategory(result.categoryId!);
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

  /// Reports whether the current suggestion's category is considered
  /// "missing" (was either never resolved, or resolved to an ID this form can't
  /// record against).
  bool get isQuickEntryCategoryMissing {
    final suggestion = quickEntrySuggestion.value;
    if (suggestion == null) return false;
    return isCategoryMissingFor(suggestion);
  }

  /// Whether [result]'s category is unusable in this form — either never
  /// resolved, or resolved to an ID this form can't actually record against.
  ///
  /// Prefer this over the [isQuickEntryCategoryMissing] getter when validating a
  /// parse that hasn't been published to [quickEntrySuggestion] yet: the getter
  /// reads that Rx and would score the *previous* keystroke's result.
  bool isCategoryMissingFor(ParsedTransactionEntity result) {
    // Nothing to record against at all, whatever the parse resolved.
    if (!quickEntryHasSelectableCategory) return true;

    final id = result.categoryId;

    // If we have no category ID at all, it's definitely missing (Case 2).
    if (id == null) return true;

    final availableIds = quickEntryAvailableCategoryIds;
    final isAvailable = availableIds.contains(id);

    '[AI_PARSING] 🔍 Checking category missing | id=$id | isAvailable=$isAvailable | availableCount=${availableIds.length}'
        .Log('QuickEntryMixin');

    return !isAvailable;
  }

  /// Alias for [isQuickEntryCategoryMissing] used by UI components to determine
  /// if a parsed category is "Missing" or "Invalid" (Case 2).
  bool get isQuickEntryCategoryInvalid => isQuickEntryCategoryMissing;

  /// List of category IDs that are currently valid/selectable in this form.
  /// Used to determine if a parsed category is "Missing" (Case 2).
  List<String> get quickEntryAvailableCategoryIds =>
      _quickEntryCategories.map((category) => category.id).toList();

  /// Whether this form currently has at least one row a parsed entry can be
  /// recorded against.
  ///
  /// Category-backed forms (expense, income) always do. The asset-backed forms
  /// (investment, borrow, lend) render an empty row until the user creates
  /// their first asset, and their submit button stays disabled — so an entry
  /// typed there has nowhere to go and must not be auto-saved.
  bool get quickEntryHasSelectableCategory => true;

  /// Cancels auto-save and reports why when this form has nothing to save
  /// into. Returns true when auto-save was blocked.
  ///
  /// No snackbar, no error key: the published suggestion chip already renders
  /// [CcLocaleKeys.quick_entry_category_missing] once this form reports
  /// [isQuickEntryCategoryInvalid], so the user still gets the message — a
  /// second copy on top of it would just be noise.
  bool _blockAutoSaveWhenNoCategory(String stage) {
    if (quickEntryHasSelectableCategory) return false;

    _cancelAutoSave();
    '[AI_PARSING] ⛔ Auto-save blocked | stage=$stage | '
            'no category/asset defined for this tab'
        .Log('QuickEntryMixin');
    return true;
  }

  bool blockAutoSaveWhenNoCategory(String stage) =>
      _blockAutoSaveWhenNoCategory(stage);

  void _onQuickEntryTextChanged() {
    _cancelAutoSave();
    if (isListeningQuickEntry.value) {
      // While dictating voice, ignore text change events to avoid launching duplicate parse timers
      return;
    }
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

    if (await getIt<AiFallbackPreferenceDataSource>().isGeminiEnabled()) {
      quickEntrySuggestion.value = null;
      return;
    }

    '[AI_PARSING] [LOCAL] 🔍 Reactive parse started | tab=$quickEntryCategoryType | text="$text"'
        .Log('QuickEntryMixin');

    // Intent detection for cross-tab switching (Reactive)
    final intent = detectQuickEntryIntent(text);
    if (intent != null) {
      '[AI_PARSING] [LOCAL] 🎯 Intent detected: $intent'.Log('QuickEntryMixin');
      final dynamic txController = Get.find<TransactionController>();
      bool isMismatch = false;
      switch (intent) {
        case QuickEntryIntent.expense:
          if (quickEntryCategoryType != CategoryType.expense) isMismatch = true;
          break;
        case QuickEntryIntent.income:
          if (quickEntryCategoryType != CategoryType.income) isMismatch = true;
          break;
        case QuickEntryIntent.investment:
          if (quickEntryCategoryType != CategoryType.investment) {
            isMismatch = true;
          }
          break;
        case QuickEntryIntent.debt:
          if (quickEntryCategoryType != CategoryType.liability ||
              quickEntryDirection != LiabilityDirection.borrow) {
            isMismatch = true;
          }
          break;
        case QuickEntryIntent.lend:
          if (quickEntryCategoryType != CategoryType.liability ||
              quickEntryDirection != LiabilityDirection.lend) {
            isMismatch = true;
          }
          break;
      }

      if (isMismatch) {
        '[AI_PARSING] [LOCAL] 🔄 Intent mismatch found (Tab: $quickEntryCategoryType vs Intent: $intent) | switching...'
            .Log('QuickEntryMixin');
        txController.switchToTabForIntent(intent);

        // Handoff to the target tab's controller
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final dynamic targetController = txController
              .getQuickEntryControllerForIntent(intent);
          if (targetController != null && targetController != this) {
            '[AI_PARSING] [LOCAL] 🤝 Handing off text to target controller: ${targetController.runtimeType}'
                .Log('QuickEntryMixin');
            if (targetController is QuickEntryMixin) {
              targetController.applyQuickEntryIntent(intent, text);
            }
            // Pass the text so the new tab can continue parsing
            targetController.quickEntryController.text = text;
            targetController.quickEntryController.selection =
                TextSelection.collapsed(offset: text.length);
          }
        });
        return;
      } else {
        '[AI_PARSING] [LOCAL] ✅ Intent matches current tab ($quickEntryCategoryType)'
            .Log('QuickEntryMixin');
        // Apply intent-based state (e.g. switching subsegments) even when tab matches.
        applyQuickEntryIntent(intent, text);
      }
    } else {
      '[AI_PARSING] [LOCAL] ❓ No clear intent detected for switching'.Log(
        'QuickEntryMixin',
      );
    }

    final local = await getIt<ParseQuickEntryUseCase>().parseLocally(
      text,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (_quickEntryDisposed || text != quickEntryController.text.trim()) {
      return;
    }

    // Ensure categories are loaded for the current tab before validating completeness.
    // This is crucial during tab-switches where the new controller was just initialized.
    if (_quickEntryCategories.isEmpty) {
      await refreshQuickEntryCategories();
    }

    // Score the fresh parse, not [isQuickEntryCategoryMissing] — the Rx still
    // holds the previous keystroke's result at this point.
    final hasAmount = local.amount != null && local.amount! > 0;
    final categoryMissing = isCategoryMissingFor(local);
    final isComplete = local.isComplete && !categoryMissing;

    // Publish the suggestion whenever an amount resolved, even if the category
    // didn't: the chip renders the "category missing (need +)" wording from
    // [isQuickEntryCategoryInvalid] instead of the success wording. Nulling it
    // here would leave the user with no feedback at all.
    quickEntrySuggestion.value = hasAmount ? local : null;

    '[AI_PARSING] [LOCAL] ✅ Local parse completed | isComplete=$isComplete | categoryMissing=$categoryMissing | categoryId=${local.categoryId} | amount=${local.amount}'
        .Log('QuickEntryMixin');

    // Proactive Prefill: Update form fields (amount and category) immediately
    // as the user types, so the form stays in sync with the visual recognition.
    if (local.amount != null) {
      amountStr.value = local.amount!.toString();
    }
    if (local.categoryId != null && !categoryMissing) {
      applyQuickEntryCategory(local.categoryId!);
    } else if (text.isNotEmpty) {
      // No usable category (never resolved, or no record in this tab carries
      // it). Clear any previous selection so the submit button stays disabled
      // until a valid category is found or picked by hand.
      clearCategorySelection();
    }

    // Auto-save should only trigger if we have BOTH a valid category and a
    // non-zero amount.
    final bool canAutoSave =
        isComplete && hasAmount && local.categoryId != null;

    if (canAutoSave && Get.context != null) {
      startAutoSaveTimer(Get.context!);
    }
  }

  /// One submission's generation token: `isCurrent` reports whether
  /// [resetQuickEntry] has since invalidated it; `resetIfCurrent` clears
  /// [isParsingQuickEntry] only if it's still the active one.
  @protected
  (bool Function(), VoidCallback) trackQuickEntryGeneration() {
    final generation = _quickEntryGeneration;
    bool isCurrent() =>
        !_quickEntryDisposed && generation == _quickEntryGeneration;
    void resetIfCurrent() {
      if (isCurrent()) isParsingQuickEntry.value = false;
    }

    return (isCurrent, resetIfCurrent);
  }

  /// Explicit "done" trigger (submit / finished voice dictation) — the only
  /// path that calls Gemini, so a network call never fires while someone
  /// is still mid-typing.
  Future<void> submitQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    final languageCode = el.EasyLocalization.of(context)?.locale.languageCode;
    final prefs = getIt<AiFallbackPreferenceDataSource>();
    final geminiEnabled = await prefs.isGeminiEnabled();
    final cloudAllowed = geminiEnabled && await prefs.isUnderDailyLimit();
    // Guards a fast double-submit from firing two concurrent cloud calls.
    if (isParsingQuickEntry.value) return;
    final text = quickEntryController.text.trim();
    if (text.isEmpty) return;

    '[AI_PARSING] [LOCAL] 🚀 Submitting quick entry | text="$text"'.Log(
      'QuickEntryMixin',
    );

    // Intent detection for cross-tab switching
    final intent = detectQuickEntryIntent(text);
    if (intent != null) {
      final dynamic txController = Get.find<TransactionController>();
      bool isMismatch = false;
      switch (intent) {
        case QuickEntryIntent.expense:
          if (quickEntryCategoryType != CategoryType.expense) isMismatch = true;
          break;
        case QuickEntryIntent.income:
          if (quickEntryCategoryType != CategoryType.income) isMismatch = true;
          break;
        case QuickEntryIntent.investment:
          if (quickEntryCategoryType != CategoryType.investment) {
            isMismatch = true;
          }
          break;
        case QuickEntryIntent.debt:
          if (quickEntryCategoryType != CategoryType.liability ||
              quickEntryDirection != LiabilityDirection.borrow) {
            isMismatch = true;
          }
          break;
        case QuickEntryIntent.lend:
          if (quickEntryCategoryType != CategoryType.liability ||
              quickEntryDirection != LiabilityDirection.lend) {
            isMismatch = true;
          }
          break;
      }

      if (isMismatch) {
        '[AI_PARSING] [LOCAL] 🔄 Intent mismatch detected during typing | switching to $intent'
            .Log('QuickEntryMixin');
        txController.switchToTabForIntent(intent);

        // Handoff to the target tab's controller
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final dynamic targetController = txController
              .getQuickEntryControllerForIntent(intent);
          if (targetController != null && targetController != this) {
            if (targetController is QuickEntryMixin) {
              targetController.applyQuickEntryIntent(intent, text);
            }
            // Pass the text so the new tab can continue parsing
            targetController.quickEntryController.text = text;
            targetController.quickEntryController.selection =
                TextSelection.collapsed(offset: text.length);
            if (geminiEnabled && targetController is QuickEntryMixin) {
              targetController.submitQuickEntry(context);
            }
          }
        });
        return;
      } else {
        // Even if the tab is correct, we might need to apply a direction/mode switch
        applyQuickEntryIntent(intent, text);
      }
    }

    _quickEntryDebounce?.cancel();
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    final (isCurrentGeneration, resetParsingIfCurrent) =
        trackQuickEntryGeneration();

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(
      text,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (!isCurrentGeneration()) return;
    '[AI_PARSING] [LOCAL] 📍 Local fallback ready | result=${local.toJson()}'
        .Log('QuickEntryMixin');

    if (!cloudAllowed && local.amount != null) {
      '[AI_PARSING] [LOCAL] ✅ Local parse found amount | applying to form and starting auto-save'
          .Log('QuickEntryMixin');
      resetParsingIfCurrent();

      // Proactively prefill form fields so the UI highlights the match immediately
      amountStr.value = local.amount!.toString();
      if (local.categoryId != null && !isCategoryMissingFor(local)) {
        applyQuickEntryCategory(local.categoryId!);
      }

      // Published before the guard so the chip can render the missing-category
      // wording even when auto-save is blocked.
      quickEntrySuggestion.value = local;
      if (_blockAutoSaveWhenNoCategory('local')) return;
      if (!isQuickEntryCategoryMissing && context.mounted) {
        startAutoSaveTimer(context);
      }
      return;
    }

    if (!context.mounted) return;

    '[AI_PARSING] [GEMINI] ☁️ Escalating to Gemini...'.Log('QuickEntryMixin');
    final cloud = await runSmartEntry(
      input: SmartEntryTextInput(text),
      local: local,
      languageCode: languageCode,
    );
    resetParsingIfCurrent();
    // The field stays editable during the round trip — re-check the text
    // still matches what was sent before applying/erroring on anything.
    if (!isCurrentGeneration() || text != quickEntryController.text.trim()) {
      '[AI_PARSING] [GEMINI] ⚠️ Generation stale after cloud call | aborting'
          .Log('QuickEntryMixin');
      return;
    }

    if (cloud.errorKey != null) {
      quickEntryErrorKey.value = cloud.errorKey;
      return;
    }
    if (cloud.rows.isNotEmpty) {
      if (context.mounted) await presentQuickEntryPreview(context, cloud.rows);
      return;
    }

    final suggestion = local;

    '[AI_PARSING] [GEMINI] ↩️ Cloud returned nothing, using local result | result=${suggestion.toJson()}'
        .Log('QuickEntryMixin');

    if (suggestion.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    // Apply proactive prefill for the cloud result
    if (suggestion.amount != null) {
      amountStr.value = suggestion.amount!.toString();
    }
    if (suggestion.categoryId != null && !isCategoryMissingFor(suggestion)) {
      applyQuickEntryCategory(suggestion.categoryId!);
    }

    // Published before the guard so the chip can render the missing-category
    // wording even when auto-save is blocked.
    quickEntrySuggestion.value = suggestion;
    if (_blockAutoSaveWhenNoCategory('cloud')) return;
    if (!isQuickEntryCategoryMissing && context.mounted) {
      startAutoSaveTimer(context);
    }
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
    final (isCurrentGeneration, resetParsingIfCurrent) =
        trackQuickEntryGeneration();

    '[AI_PARSING] 📸 Image picker started | fromCamera=$fromCamera'.Log(
      'QuickEntryMixin',
    );
    final pickResult = await CcReceiptScanHelper.pickReceiptImage(
      fromCamera: fromCamera,
    );
    if (!isCurrentGeneration()) return;
    final picked = pickResult.image;
    if (picked == null) {
      '[AI_PARSING] ❌ No image picked'.Log('QuickEntryMixin');
      resetParsingIfCurrent();
      // A denied permission gets explicit feedback; a plain cancel stays silent.
      if (pickResult.permissionDenied) {
        quickEntryErrorKey.value =
            CcLocaleKeys.quick_entry_photo_permission_denied;
      }
      return;
    }

    if (!context.mounted) {
      resetParsingIfCurrent();
      return;
    }
    await resolvePickedReceipt(context, picked);
  }

  @protected
  Future<void> resolvePickedReceipt(
    BuildContext context,
    PickedReceiptImage picked,
  ) async {
    final (isCurrentGeneration, resetParsingIfCurrent) =
        trackQuickEntryGeneration();
    final languageCode = el.EasyLocalization.of(context)?.locale.languageCode;

    '[AI_PARSING] 🔍 Running OCR...'.Log('QuickEntryMixin');
    final ocrText = await CcReceiptScanHelper.recognizeText(picked.path);
    if (!isCurrentGeneration()) return;
    '[AI_PARSING] 📝 OCR completed | textLength=${ocrText.length}'.Log(
      'QuickEntryMixin',
    );

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(
      ocrText,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (!isCurrentGeneration()) return;
    '[AI_PARSING] 📍 OCR-based local fallback ready | result=${local.toJson()}'
        .Log('QuickEntryMixin');

    final prefs = getIt<AiFallbackPreferenceDataSource>();
    final cloudAllowed =
        await prefs.isGeminiEnabled() && await prefs.isUnderDailyLimit();
    if (!isCurrentGeneration()) return;
    if (!cloudAllowed && _isAmountPlausible(local.amount)) {
      '[AI_PARSING] ✅ OCR parse found a plausible amount | cloud unavailable, using local result'
          .Log('QuickEntryMixin');
      resetParsingIfCurrent();
      quickEntrySuggestion.value = local;
      return;
    }

    if (!context.mounted) return;

    '[AI_PARSING] ☁️ Escalating image to Gemini...'.Log('QuickEntryMixin');
    final cloud = await runSmartEntry(
      input: SmartEntryImagesInput([
        (bytes: picked.bytes, mimeType: picked.mimeType),
      ]),
      local: local,
      languageCode: languageCode,
    );
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    if (cloud.errorKey != null) {
      quickEntryErrorKey.value = cloud.errorKey;
      return;
    }
    if (cloud.rows.isNotEmpty) {
      if (context.mounted) await presentQuickEntryPreview(context, cloud.rows);
      return;
    }

    final suggestion = local;

    '[AI_PARSING] ↩️ Cloud returned nothing, using local OCR result | result=${suggestion.toJson()}'
        .Log('QuickEntryMixin');

    if (suggestion.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = suggestion;
    if (_blockAutoSaveWhenNoCategory('image')) return;
    if (!isQuickEntryCategoryMissing && context.mounted) {
      startAutoSaveTimer(context);
    }
  }

  Future<void> toggleVoiceQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;

    '[VoiceWorkflow] 🟢 toggleVoiceQuickEntry triggered | isListening=${isListeningQuickEntry.value}'
        .Log('QuickEntryMixin');

    bool voiceSubmitted = false;

    void triggerVoiceSubmit(String rawText, String source) {
      if (voiceSubmitted || _quickEntryDisposed) return;
      voiceSubmitted = true;
      isListeningQuickEntry.value = false;
      _cancelAutoSave();

      final text = rawText.trim();
      if (text.isNotEmpty && !isParsingQuickEntry.value) {
        '[VoiceWorkflow] 🚀 Submitting voice result via $source | text="$text"'
            .Log('QuickEntryMixin');
        submitQuickEntry(context);
      }
    }

    if (isListeningQuickEntry.value) {
      '[VoiceWorkflow] 🛑 Manual stop requested'.Log('QuickEntryMixin');
      await CcSpeechHelper.stopListening();
      triggerVoiceSubmit(quickEntryController.text, 'manualStop');
      return;
    }

    final status = await Permission.microphone.request();
    '[VoiceWorkflow] 🔒 Microphone permission status: $status'.Log(
      'QuickEntryMixin',
    );

    if (!status.isGranted) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_mic_permission_denied;
      return;
    }

    hideKeypad();
    quickEntryErrorKey.value = null;
    isListeningQuickEntry.value = true;

    final started = await CcSpeechHelper.startListening(
      onResult: (recognizedWords, isFinal) {
        if (_quickEntryDisposed) return;
        '[VoiceWorkflow] 🗣️ Voice recognized words: "$recognizedWords" | isFinal=$isFinal'
            .Log('QuickEntryMixin');

        quickEntryController.text = recognizedWords;
        quickEntryController.selection = TextSelection.collapsed(
          offset: recognizedWords.length,
        );
      },
      onListeningStopped: () {
        if (_quickEntryDisposed) return;
        '[VoiceWorkflow] 🏁 Voice listening session completed'.Log(
          'QuickEntryMixin',
        );
        triggerVoiceSubmit(quickEntryController.text, 'onListeningStopped');
      },
    );

    if (_quickEntryDisposed) return;

    if (!started) {
      if (!CcSpeechHelper.isListening) {
        '[VoiceWorkflow] ❌ Failed to start speech recognizer'.Log(
          'QuickEntryMixin',
        );
        isListeningQuickEntry.value = false;
        quickEntryErrorKey.value =
            CcLocaleKeys.quick_entry_mic_permission_denied;
      }
    }
  }

  /// Applies a resolved `categoryId` to the category-picker UI. Investment
  /// overrides this as a no-op — its category always comes from the chosen
  /// asset, a manual pick by design.
  void applyQuickEntryCategory(String categoryId) {
    pendingPrefillCategoryId.value = categoryId;

    // Proactive resolution: if we can find the real CategoryEntity in our
    // local cache, tell the host controller to select it immediately.
    // This ensures the form is valid (canSubmit = true) for auto-save
    // without waiting for the UI selection-grid to remount.
    final category = findQuickEntryCategory(categoryId);
    if (category != null) {
      applyResolvedCategory(category);
    }
  }

  /// Optional hook for controllers to apply a synchronously resolved
  /// [CategoryEntity] to their internal state.
  void applyResolvedCategory(CategoryEntity category) {}

  /// Pre-fills whichever fields [result] resolved; a null field is left at
  /// the form's existing default for the user to fill in by hand.
  void applyQuickEntryParse(ParsedTransactionEntity result) {
    _cancelAutoSave();
    '[AI_PARSING] 📥 Applying parse result | result=${result.toJson()}'.Log(
      'QuickEntryMixin',
    );
    if (result.amount != null) {
      amountStr.value = result.amount!.toString();
    } else {
      amountStr.value = '0';
    }

    if (result.categoryId != null) {
      applyQuickEntryCategory(result.categoryId!);
    }
    if (result.walletId != null) {
      setWalletId(result.walletId!);
    }
    if (result.date != null) setDate(result.date!);
    if (result.note != null) noteController.text = result.note!;
    quickEntrySuggestion.value = null;
    quickEntryController.clear();
  }

  void dismissQuickEntrySuggestion() {
    quickEntrySuggestion.value = null;
  }

  List<String> get quickEntryCloudCategoryTypes => [quickEntryCategoryType];

  int get quickEntryCloudMaxTransactions => 1;

  bool get quickEntryCommitsDirectly => false;

  @protected
  Future<QuickEntryCloudResult> runSmartEntry({
    required SmartEntryInput input,
    required ParsedTransactionEntity local,
    String? languageCode,
  }) async {
    final result = await getIt<ParseSmartEntryUseCase>().call(
      input: input,
      categoryTypes: quickEntryCloudCategoryTypes,
      groupIds: quickEntryCategoryGroupIds,
      languageCode: languageCode,
      maxTransactions: quickEntryCloudMaxTransactions,
      localResult: local,
    );
    final failure = result.tryGetError();
    if (failure != null) {
      '[AI_PARSING] [GEMINI] ❌ Smart entry failed | ${failure.message}'.Log(
        'QuickEntryMixin',
      );
    }
    return (
      rows: result.tryGetSuccess() ?? const [],
      errorKey: switch (failure?.message) {
        ParseSmartEntryUseCase.geminiDisabledReason =>
          CcLocaleKeys.report_ai_advice_gemini_disabled,
        ParseSmartEntryUseCase.dailyLimitReachedReason =>
          CcLocaleKeys.quick_entry_daily_limit_reached,
        _ => null,
      },
    );
  }

  @protected
  Future<void> presentQuickEntryPreview(
    BuildContext context,
    List<ParsedTransactionEntity> rows,
  ) async {
    quickEntrySuggestion.value = null;
    final types = quickEntryCloudCategoryTypes;
    final groupIds = quickEntryCategoryGroupIds;
    final categories =
        (await getIt<GetCategoriesUseCase>().call()).tryGetSuccess() ??
        const <CategoryEntity>[];
    if (!context.mounted || _quickEntryDisposed) return;

    final state = SmartEntryPreviewState(
      parsed: rows,
      categories: [
        for (final category in categories)
          if (category.isEnabled &&
              types.contains(category.type) &&
              (groupIds == null || groupIds.contains(category.groupId)))
            category,
      ],
      wallets: wallets.toList(),
      config: SmartEntryPreviewConfig(
        types: types,
        currencyCode: currencyCode.value,
        showCategory: quickEntryShowsCategoryInLabel,
        appliesToForm: !quickEntryCommitsDirectly,
      ),
      defaultWalletId: selectedWalletId.value ?? '',
    );
    final committed = await SmartEntryPreviewSheet.show(
      context,
      state: state,
      onConfirm: (edited) => commitQuickEntryRows(context, edited),
    );
    if (committed == true && !_quickEntryDisposed) {
      quickEntryController.clear();
    }
  }

  Future<SmartEntryCommitResult> commitQuickEntryRows(
    BuildContext context,
    List<ParsedTransactionEntity> rows,
  ) async {
    applyQuickEntryParse(rows.first);
    return SmartEntryCommitResult(saved: rows.length);
  }

  /// Sanity check for parsed amounts to avoid misidentifying phone numbers
  /// or serial numbers as transaction values.
  /// Anything over 500 million VND for a single OCR entry is escalated to Gemini.
  bool _isAmountPlausible(int? amount) {
    if (amount == null) return false;
    // 500,000,000 VND (~$20k) is a safe threshold for "Automatic" local parsing.
    // Larger amounts are legally/financially significant and worth the AI check.
    const int threshold = 500000000;
    return amount > 0 && amount <= threshold;
  }
}
