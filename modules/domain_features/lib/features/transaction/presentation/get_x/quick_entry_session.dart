import 'dart:async';

import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../domain/entities/smart_entry_input.dart';
import '../../domain/usecases/parse_smart_entry_usecase.dart';
import '../helper/receipt_image_picker_helper.dart';
import '../widgets/smart_entry_preview_sheet.dart';
import 'quick_entry_auto_save_helper.dart';
import 'smart_entry_preview_state.dart';
import 'transaction_form_controller.dart';
import 'quick_entry_category_cache.dart';
import 'quick_entry_handler.dart';
import 'quick_entry_image_input.dart';
import 'quick_entry_text_input.dart';
import 'quick_entry_voice_input.dart';

typedef QuickEntryCloudResult = ({
  List<ParsedTransactionEntity> rows,
  String? errorKey,
});

/// Shared "AI Smart Entry" quick-entry capability: a free-text field with
/// mic dictation and receipt-photo scan, parsed locally then always
/// escalated to Gemini (see [ParseSmartEntryUseCase], which enforces the
/// daily cap).
///
/// Owned by each form controller (`quickEntry`); the controller calls
/// [initQuickEntry]/[disposeQuickEntry]/[resetQuickEntry] from its own
/// `onInit`/`onClose`/reset. Per-form behaviour comes from the hooks on
/// [TransactionFormController].
class QuickEntrySession with WidgetsBindingObserver {
  QuickEntrySession(this.host, this.handler);

  /// The form this session fills in; also supplies the per-form hooks
  /// (category type, groups, direction, how a category is applied, ...).
  final TransactionFormController host;
  final QuickEntryHandler handler;

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

  bool _quickEntryDisposed = false;

  bool get isQuickEntryDisposed => _quickEntryDisposed;

  /// Bumped by [resetQuickEntry] to invalidate any submission still in
  /// flight, so a stale cloud response can't overwrite a newer entry.
  int _quickEntryGeneration = 0;

  /// Call from the host's `onInit`.
  void initQuickEntry() {
    WidgetsBinding.instance.addObserver(this);
    quickEntryController.addListener(_text.onTextChanged);
    refreshQuickEntryCategories();
  }

  /// Call from the host's `onClose`.
  void disposeQuickEntry() {
    WidgetsBinding.instance.removeObserver(this);
    _quickEntryDisposed = true;
    _text.dispose();
    _cancelAutoSave();
    quickEntryController
      ..removeListener(_text.onTextChanged)
      ..dispose();
    // Only stop it if this instance holds it — the recognizer is a global singleton.
    if (isListeningQuickEntry.value) {
      unawaited(handler.speech.stopListening());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _cancelAutoSave();
    }
  }

  /// Bumps the generation to invalidate any in-flight cloud call.
  void resetQuickEntry() {
    _cancelAutoSave();
    host.pendingPrefillCategoryId.value = null;
    quickEntrySuggestion.value = null;
    quickEntryErrorKey.value = null;
    quickEntryController.clear();
    _quickEntryGeneration++;
    isParsingQuickEntry.value = false;
  }

  void _cancelAutoSave() {
    _autoSaveHelper.cancelAutoSave();
  }

  void cancelAutoSaveCountdown() => _cancelAutoSave();

  void cancelAutoSaveManually() {
    _cancelAutoSave();
    // Also clear the suggestion so it doesn't linger after a manual cancel
    quickEntrySuggestion.value = null;
  }

  Future<void> startAutoSaveTimer(BuildContext context) async {
    _autoSaveHelper.startAutoSaveTimer(
      context: context,
      hasSelectableCategory: host.quickEntryHasSelectableCategory,
      onSave: () {
        final suggestion = quickEntrySuggestion.value;
        if (suggestion != null) {
          applyQuickEntryParse(suggestion);
          host.submitForm(context);
        }
      },
    );
  }

  @protected
  void startAutoSaveCountdown(VoidCallback onElapsed) {
    _autoSaveHelper.startAutoSaveCountdown(onElapsed);
  }

  late final QuickEntryCategoryCache _categories = QuickEntryCategoryCache(
    host,
    handler.parser,
  );

  /// Reloads the categories a parse may resolve to; see
  /// [QuickEntryCategoryCache.refresh].
  Future<void> refreshQuickEntryCategories() => _categories.refresh();

  CategoryEntity? findQuickEntryCategory(String id) => _categories.find(id);

  /// Display label for a suggestion, e.g. "50.00k · Cà phê · 12/08".
  String quickEntryResultLabel(ParsedTransactionEntity result) =>
      _categories.labelFor(result);

  /// Whether the published suggestion's category is unusable in this form.
  bool get isQuickEntryCategoryMissing {
    final suggestion = quickEntrySuggestion.value;
    if (suggestion == null) return false;
    return isCategoryMissingFor(suggestion);
  }

  /// Like [isQuickEntryCategoryMissing], for a parse not yet published to
  /// [quickEntrySuggestion] (that getter would score the previous keystroke).
  bool isCategoryMissingFor(ParsedTransactionEntity result) =>
      _categories.isMissingFor(result);

  /// Alias of [isQuickEntryCategoryMissing] for the suggestion chip.
  bool get isQuickEntryCategoryInvalid => isQuickEntryCategoryMissing;

  /// The default for [TransactionFormController.quickEntryAvailableCategoryIds].
  List<String> get loadedCategoryIds => _categories.ids;

  /// Cancels auto-save and reports why when this form has nothing to save
  /// into. Returns true when auto-save was blocked.
  ///
  /// No snackbar, no error key: the published suggestion chip already renders
  /// [CcLocaleKeys.quick_entry_category_missing] once this form reports
  /// [isQuickEntryCategoryInvalid], so the user still gets the message — a
  /// second copy on top of it would just be noise.
  bool _blockAutoSaveWhenNoCategory(String stage) {
    if (host.quickEntryHasSelectableCategory) return false;

    _cancelAutoSave();
    '[AI_PARSING] ⛔ Auto-save blocked | stage=$stage | '
            'no category/asset defined for this tab'
        .Log('QuickEntrySession');
    return true;
  }

  bool blockAutoSaveWhenNoCategory(String stage) =>
      _blockAutoSaveWhenNoCategory(stage);

  /// One submission's generation token: `isCurrent` reports whether
  /// [resetQuickEntry] has since invalidated it; `resetIfCurrent` clears
  /// [isParsingQuickEntry] only if it's still the active one.
  (bool Function(), VoidCallback) trackQuickEntryGeneration() {
    final generation = _quickEntryGeneration;
    bool isCurrent() =>
        !_quickEntryDisposed && generation == _quickEntryGeneration;
    void resetIfCurrent() {
      if (isCurrent()) isParsingQuickEntry.value = false;
    }

    return (isCurrent, resetIfCurrent);
  }

  late final QuickEntryTextInput _text = QuickEntryTextInput(this);

  /// Explicit "done" trigger (submit button / finished dictation) — the only
  /// path that calls the cloud AI; see [QuickEntryTextInput.submitQuickEntry].
  Future<void> submitQuickEntry(BuildContext context) =>
      _text.submitQuickEntry(context);

  late final QuickEntryImageInput _image = QuickEntryImageInput(this);
  late final QuickEntryVoiceInput _voice = QuickEntryVoiceInput(this);

  /// Reentrancy gate for receipt-photo entry; see [QuickEntryImageInput].
  bool beginQuickEntryImage() => _image.beginQuickEntryImage();

  void cancelQuickEntryImage() => _image.cancelQuickEntryImage();

  Future<void> submitQuickEntryFromImage(
    BuildContext context, {
    required bool fromCamera,
  }) => _image.submitQuickEntryFromImage(context, fromCamera: fromCamera);

  Future<void> resolvePickedReceipt(
    BuildContext context,
    ReceiptImage picked,
  ) => _image.resolvePickedReceipt(context, picked);

  Future<void> toggleVoiceQuickEntry(BuildContext context) =>
      _voice.toggleVoiceQuickEntry(context);

  /// Default for [TransactionFormController.applyQuickEntryCategory]: marks
  /// the id for the category picker and selects it right away when cached.
  void applyCategoryDefault(String categoryId) {
    host.pendingPrefillCategoryId.value = categoryId;

    // Proactive resolution: if we can find the real CategoryEntity in our
    // local cache, tell the host controller to select it immediately.
    // This ensures the form is valid (canSubmit = true) for auto-save
    // without waiting for the UI selection-grid to remount.
    final category = findQuickEntryCategory(categoryId);
    if (category != null) {
      host.applyResolvedCategory(category);
    }
  }

  /// Pre-fills whichever fields [result] resolved; a null field is left at
  /// the form's existing default for the user to fill in by hand.
  void applyQuickEntryParse(ParsedTransactionEntity result) {
    _cancelAutoSave();
    '[AI_PARSING] 📥 Applying parse result | result=${result.toJson()}'.Log(
      'QuickEntrySession',
    );
    if (result.amount != null) {
      host.amountStr.value = result.amount!.toString();
    } else {
      host.amountStr.value = '0';
    }

    if (result.categoryId != null) {
      host.applyQuickEntryCategory(result.categoryId!);
    }
    if (result.walletId != null) {
      host.setWalletId(result.walletId!);
    }
    if (result.date != null) host.setDate(result.date!);
    if (result.note != null) host.noteController.text = result.note!;
    quickEntrySuggestion.value = null;
    quickEntryController.clear();
  }

  void dismissQuickEntrySuggestion() {
    quickEntrySuggestion.value = null;
  }

  List<String> get quickEntryCloudCategoryTypes => [
    host.quickEntryCategoryType,
  ];

  int get quickEntryCloudMaxTransactions => 1;

  bool get quickEntryCommitsDirectly => false;

  Future<QuickEntryCloudResult> runSmartEntry({
    required SmartEntryInput input,
    required ParsedTransactionEntity local,
    String? languageCode,
  }) async {
    final result = await handler.parser.parseSmart(
      input: input,
      categoryTypes: quickEntryCloudCategoryTypes,
      groupIds: host.quickEntryCategoryGroupIds,
      languageCode: languageCode,
      maxTransactions: quickEntryCloudMaxTransactions,
      localResult: local,
    );
    final failure = result.tryGetError();
    if (failure != null) {
      '[AI_PARSING] [GEMINI] ❌ Smart entry failed | ${failure.message}'.Log(
        'QuickEntrySession',
      );
    }
    return (
      rows: result.tryGetSuccess() ?? const [],
      errorKey: switch (failure?.message) {
        ParseSmartEntryUseCase.geminiDisabledReason =>
          CcLocaleKeys.report_ai_advice_gemini_disabled,
        ParseSmartEntryUseCase.deviceNotGenuineReason =>
          CcLocaleKeys.quick_entry_device_not_genuine,
        ParseSmartEntryUseCase.dailyLimitReachedReason =>
          CcLocaleKeys.quick_entry_daily_limit_reached,
        _ => null,
      },
    );
  }

  Future<void> presentQuickEntryPreview(
    BuildContext context,
    List<ParsedTransactionEntity> rows,
  ) async {
    quickEntrySuggestion.value = null;
    final types = quickEntryCloudCategoryTypes;
    final groupIds = host.quickEntryCategoryGroupIds;
    final categories =
        (await handler.parser.loadCategories()).tryGetSuccess() ??
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
      wallets: host.wallets.toList(),
      config: SmartEntryPreviewConfig(
        types: types,
        currencyCode: host.currencyCode.value,
        showCategory: host.quickEntryShowsCategoryInLabel,
        appliesToForm: !quickEntryCommitsDirectly,
      ),
      defaultWalletId: host.selectedWalletId.value ?? '',
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
}
