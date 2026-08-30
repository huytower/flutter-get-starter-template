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
import '../../../../core/helper/quick_entry_parser_helper.dart';
import '../../../liability/domain/entities/liability_entity.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/usecases/parse_quick_entry_usecase.dart';
import 'transaction_controller.dart';
import 'transaction_form_controller.dart';

mixin QuickEntryMixin on TransactionFormController
    implements WidgetsBindingObserver {
  /// Category type quick-entry searches/prefills within.
  String get quickEntryCategoryType;
  List<String>? get quickEntryCategoryGroupIds => null;
  RxInt get categoryKey;
  Rx<String?> get pendingPrefillCategoryId;

  final TextEditingController quickEntryController = TextEditingController();
  final Rx<QuickEntryParseResult?> quickEntrySuggestion = Rx<QuickEntryParseResult?>(null);
  final RxBool isParsingQuickEntry = false.obs;
  final RxBool isListeningQuickEntry = false.obs;

  /// Remaining seconds until auto-save triggers. VIP only.
  final RxInt autoSaveCountdown = 0.obs;
  final RxBool isVip = false.obs;
  Timer? _autoSaveTimer;

  /// Locale key for an inline status message; null means nothing to show.
  final Rx<String?> quickEntryErrorKey = Rx<String?>(null);

  List<CategoryEntity> _quickEntryCategories = [];
  Timer? _quickEntryDebounce;
  bool _quickEntryDisposed = false;
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
    quickEntryController
      ..removeListener(_onQuickEntryTextChanged)
      ..dispose();
    // Only stop it if this instance holds it — the recognizer is a global singleton.
    if (isListeningQuickEntry.value) {
      CcSpeechHelper.stopListening();
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
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    autoSaveCountdown.value = 0;
  }

  void cancelAutoSaveManually() {
    _cancelAutoSave();
    // Also clear the suggestion so it doesn't linger after a manual cancel
    quickEntrySuggestion.value = null;
  }

  Future<void> startAutoSaveTimer(BuildContext context) async {
    _cancelAutoSave();

    final settings = await getIt<GetProfileSettingsUseCase>().call();
    isVip.value = settings.isVip;

    if (!isVip.value) return;

    autoSaveCountdown.value = 2;
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (autoSaveCountdown.value > 1) {
        autoSaveCountdown.value--;
      } else {
        _cancelAutoSave();
        final suggestion = quickEntrySuggestion.value;
        if (suggestion != null) {
          applyQuickEntryParse(suggestion);
          submitForm(context);
        }
      }
    });
  }

  String get quickEntryDirection => '';

  void applyQuickEntryIntent(QuickEntryIntent intent, String text) {}

  Future<void> refreshQuickEntryCategories() async {
    final result = await getIt<GetCategoriesUseCase>().call();
    final groupIds = quickEntryCategoryGroupIds;
    _quickEntryCategories =
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
  }

  CategoryEntity? _findQuickEntryCategory(String id) {
    for (final category in _quickEntryCategories) {
      if (category.id == id) return category;
    }
    return null;
  }

  bool get quickEntryShowsCategoryInLabel => true;

  String quickEntryResultLabel(QuickEntryParseResult result) {
    final parts = <String>[];
    if (result.amount != null) {
      parts.add(formatVndShort(result.amount!));
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

  bool get isQuickEntryCategoryMissing {
    final suggestion = quickEntrySuggestion.value;
    if (suggestion == null) return false;
    final id = suggestion.categoryId;
    if (id == null) return true;
    return !quickEntryAvailableCategoryIds.contains(id);
  }

  bool get isQuickEntryCategoryInvalid {
    final id = quickEntrySuggestion.value?.categoryId;
    if (id == null) return false;

    final availableIds = quickEntryAvailableCategoryIds;
    final isAvailable = availableIds.contains(id);
    '[AI_PARSING] 🔍 Checking category missing | id=$id | isAvailable=$isAvailable | availableCount=${availableIds.length}'
        .Log('QuickEntryMixin');
    return !isAvailable;
  }

  List<String> get quickEntryAvailableCategoryIds =>
      _quickEntryCategories.map((category) => category.id).toList();

  void _onQuickEntryTextChanged() {
    _cancelAutoSave();
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

    final isComplete = local.isComplete && !isQuickEntryCategoryMissing;
    quickEntrySuggestion.value = isComplete ? local : null;

    if (isComplete && Get.context != null) {
      startAutoSaveTimer(Get.context!);
    }
  }

  (bool Function(), VoidCallback) _trackGeneration() {
    final generation = _quickEntryGeneration;
    bool isCurrent() =>
        !_quickEntryDisposed && generation == _quickEntryGeneration;
    void resetIfCurrent() {
      if (isCurrent()) isParsingQuickEntry.value = false;
    }

    return (isCurrent, resetIfCurrent);
  }

  Future<bool> _passCloudGate({
    required bool Function() isCurrentGeneration,
    required VoidCallback resetParsingIfCurrent,
  }) async {
    final prefs = getIt<AiFallbackPreferenceDataSource>();
    if (!await prefs.tryConsumeDailyCall()) {
      if (!isCurrentGeneration()) return false;
      resetParsingIfCurrent();
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_daily_limit_reached;
      return false;
    }

    return true;
  }

  Future<void> submitQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    // Guards a fast double-submit from firing two concurrent cloud calls.
    if (isParsingQuickEntry.value) return;
    final text = quickEntryController.text.trim();
    if (text.isEmpty) return;

    '[AI_PARSING] 🚀 Submitting quick entry | text="$text"'.Log(
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
          if (quickEntryCategoryType != CategoryType.debtLoan ||
              quickEntryDirection != LiabilityDirection.borrow) {
            isMismatch = true;
          }
          break;
        case QuickEntryIntent.lend:
          if (quickEntryCategoryType != CategoryType.debtLoan ||
              quickEntryDirection != LiabilityDirection.lend) {
            isMismatch = true;
          }
          break;
      }

      if (isMismatch) {
        '[AI_PARSING] 🔄 Intent mismatch | switching to $intent'.Log(
          'QuickEntryMixin',
        );
        txController.switchToTabForIntent(intent);

        // Handoff to the target tab's controller
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final dynamic targetController = txController
              .getQuickEntryControllerForIntent(intent);
          if (targetController != null && targetController != this) {
            if (targetController is QuickEntryMixin) {
              targetController.applyQuickEntryIntent(intent, text);
            }
            targetController.quickEntryController.text = text;
            unawaited(targetController.submitQuickEntry(context));
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
    final (isCurrentGeneration, resetParsingIfCurrent) = _trackGeneration();

    final parseUseCase = getIt<ParseQuickEntryUseCase>();
    final local = await parseUseCase.parseLocally(
      text,
      categoryType: quickEntryCategoryType,
      groupIds: quickEntryCategoryGroupIds,
    );
    if (!isCurrentGeneration()) return;
    '[AI_PARSING] 📍 Local fallback ready | result=${local.toJson()}'.Log(
      'QuickEntryMixin',
    );

    if (local.amount != null) {
      '[AI_PARSING] ✅ Local parse found amount | short-circuiting to suggestion chip'
          .Log('QuickEntryMixin');
      resetParsingIfCurrent();
      quickEntrySuggestion.value = local;
      if (!isQuickEntryCategoryMissing) {
        startAutoSaveTimer(context);
      }
      return;
    }

    QuickEntryParseResult? cloudResult;
    if (getIt<UserLevelController>().status.value.isVip) {
      if (!await _passCloudGate(
        isCurrentGeneration: isCurrentGeneration,
        resetParsingIfCurrent: resetParsingIfCurrent,
      )) {
        '[AI_PARSING] ⛔ Cloud gate blocked escalation'.Log('QuickEntryMixin');
        return;
      }

      '[AI_PARSING] ☁️ Escalating to Gemini...'.Log('QuickEntryMixin');
      cloudResult = await parseUseCase.parseWithCloud(
        text: text,
        localResult: local,
        categoryType: quickEntryCategoryType,
        groupIds: quickEntryCategoryGroupIds,
      );
    }
    resetParsingIfCurrent();
    // The field stays editable during the round trip — re-check the text
    // still matches what was sent before applying/erroring on anything.
    if (!isCurrentGeneration() || text != quickEntryController.text.trim()) {
      '[AI_PARSING] ⚠️ Generation stale after cloud call | aborting'.Log(
        'QuickEntryMixin',
      );
      return;
    }

    // Cloud failing outright (offline, API disabled) shouldn't throw away a
    // local result that was already good enough to be worth escalating.
    final suggestion = (cloudResult != null && !cloudResult.isEmpty)
        ? cloudResult
        : local;

    '[AI_PARSING] ✨ Final suggestion resolved | cloudSuccess=${cloudResult != null} | result=${suggestion.toJson()}'
        .Log('QuickEntryMixin');

    if (suggestion.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = suggestion;
    if (!isQuickEntryCategoryMissing) {
      startAutoSaveTimer(context);
    }
  }

  bool beginQuickEntryImage() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return false;
    }
    if (isParsingQuickEntry.value) return false;
    quickEntryErrorKey.value = null;
    isParsingQuickEntry.value = true;
    return true;
  }

  void cancelQuickEntryImage() {
    isParsingQuickEntry.value = false;
  }

  Future<void> submitQuickEntryFromImage(
    BuildContext context, {
    required bool fromCamera,
  }) async {
    final (isCurrentGeneration, resetParsingIfCurrent) = _trackGeneration();

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

    final bool isPerfect = local.amount != null && _isAmountPlausible(local.amount);

    if (isPerfect) {
      '[AI_PARSING] ✅ OCR parse was complete and plausible | skipping cloud escalation'
          .Log('QuickEntryMixin');
      resetParsingIfCurrent();
      quickEntrySuggestion.value = local;
      return;
    }

    QuickEntryParseResult? cloudResult;
    if (getIt<UserLevelController>().status.value.isVip) {
      if (!await _passCloudGate(
        isCurrentGeneration: isCurrentGeneration,
        resetParsingIfCurrent: resetParsingIfCurrent,
      )) {
        '[AI_PARSING] ⛔ Cloud gate blocked image escalation'.Log(
          'QuickEntryMixin',
        );
        return;
      }

      '[AI_PARSING] ☁️ Escalating image to Gemini...'.Log('QuickEntryMixin');
      cloudResult = await parseUseCase.parseImageWithCloud(
        imageBytes: picked.bytes,
        mimeType: picked.mimeType,
        localResult: local,
        categoryType: quickEntryCategoryType,
        groupIds: quickEntryCategoryGroupIds,
      );
    }
    resetParsingIfCurrent();
    if (!isCurrentGeneration()) return;

    // Cloud failing outright shouldn't throw away a local (OCR-text) result
    // that was already good enough to be worth escalating.
    final suggestion = (cloudResult != null && !cloudResult.isEmpty)
        ? cloudResult
        : local;

    '[AI_PARSING] ✨ Final image suggestion resolved | cloudSuccess=${cloudResult != null} | result=${suggestion.toJson()}'
        .Log('QuickEntryMixin');

    if (suggestion.isEmpty) {
      quickEntryErrorKey.value = CcLocaleKeys.quick_entry_could_not_parse;
      return;
    }

    quickEntrySuggestion.value = suggestion;
    if (!isQuickEntryCategoryMissing) {
      startAutoSaveTimer(context);
    }
  }

  Future<void> toggleVoiceQuickEntry(BuildContext context) async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) return;
    if (isListeningQuickEntry.value) {
      await CcSpeechHelper.stopListening();
      isListeningQuickEntry.value = false;
      return;
    }

    // Explicitly check and request microphone permission before showing the
    // "listening" state or starting the speech engine.
    final status = await Permission.microphone.request();
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
      if (!CcSpeechHelper.isListening) {
        isListeningQuickEntry.value = false;
        quickEntryErrorKey.value =
            CcLocaleKeys.quick_entry_mic_permission_denied;
      }
    }
  }

  void applyQuickEntryCategory(String categoryId) {
    pendingPrefillCategoryId.value = categoryId;
    final category = _findQuickEntryCategory(categoryId);
    if (category != null) {
      applyResolvedCategory(category);
    }
  }

  /// Optional hook for controllers to apply a synchronously resolved
  /// [CategoryEntity] to their internal state.
  void applyResolvedCategory(CategoryEntity category) {}

  /// Pre-fills whichever fields [result] resolved; a null field is left at
  /// the form's existing default for the user to fill in by hand.
  void applyQuickEntryParse(QuickEntryParseResult result) {
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
    if (result.date != null) setDate(result.date!);
    if (result.note != null) noteController.text = result.note!;
    quickEntrySuggestion.value = null;
    quickEntryController.clear();
  }

  void dismissQuickEntrySuggestion() {
    quickEntrySuggestion.value = null;
  }

  bool _isAmountPlausible(int? amount) {
    if (amount == null) return false;
    const int threshold = 500000000;
    return amount > 0 && amount <= threshold;
  }
}
