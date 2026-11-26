import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_smart_suggestion_chip.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/di/di.dart';
import '../../../guideline/export_guideline.dart';
import '../../../profile/presentation/widgets/ai_consent_sheet.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/quick_entry_batch_session.dart';
import '../get_x/quick_entry_session.dart';
import '../get_x/smart_suggestion_source.dart';
import '../get_x/transaction_controller.dart';
import '../get_x/transaction_form_controller.dart';
import 'quick_entry_section.dart';
import 'receipt_source_sheet.dart';

class TransactionHeaderBanner extends StatelessWidget {
  const TransactionHeaderBanner({
    super.key,
    required this.controller,
    required this.guideline,
    this.expenseFormController,
    this.hideGuidelineDescription = false,
  });

  final TransactionController controller;
  final GuidelineProvider guideline;
  final ExpenseFormController? expenseFormController;

  /// Shows only the challenge title (one line) — for the one-row header on
  /// short wide windows, where a wrapped description would not fit.
  final bool hideGuidelineDescription;

  bool _hasSupportedLanguageAndCurrency(BuildContext context) {
    final languageCode = el.EasyLocalization.of(
      context,
    )?.locale.languageCode.toLowerCase();
    final currencyCode = CurrencyConstants.currentPrimaryCurrency.toUpperCase();
    return (languageCode == 'vi' || languageCode == 'en') &&
        currencyCode == 'VND';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = CurrencyConstants.onCurrencyChanged.value;
      return _buildContent(context);
    });
  }

  Widget _buildContent(BuildContext context) {
    final remainingSteps = guideline.remainingGuidelineStep;
    final hasGuidelineComplete = remainingSteps == 0;

    final tabs = controller.visibleTabs;
    final activeTabIndex = controller.selectedTabIndex.value;
    final activeTab = tabs[activeTabIndex.clamp(0, tabs.length - 1)];

    if (hasGuidelineComplete) {
      return _buildAiComponents(context, activeTab);
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          guideline.hasBannerHidden = true;
        }
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          guideline.hasBannerHidden = false;
        }
      },
      child: TransactionChallengeBanner(
        shouldHideDescription: hideGuidelineDescription,
      ),
    );
  }

  TransactionFormController? _quickEntryControllerFor(TransactionTabKind tab) {
    return (tab == TransactionTabKind.expense && expenseFormController != null)
        ? expenseFormController
        : controller.getQuickEntryControllerForTab(tab);
  }

  SmartSuggestionSource? _suggestionSourceFor(TransactionTabKind tab) {
    final Object? source = _quickEntryControllerFor(tab);
    return source is SmartSuggestionSource ? source : null;
  }

  Widget _buildAiComponents(
    BuildContext context,
    TransactionTabKind activeTab,
  ) {
    if (!_hasSupportedLanguageAndCurrency(context)) {
      return const SizedBox.shrink();
    }

    final quickEntry = _quickEntryControllerFor(activeTab);

    if (quickEntry == null) return const SizedBox.shrink();

    final suggestionSource = _suggestionSourceFor(activeTab);

    final canUseAiSmartEntry =
        getIt<UserLevelProvider>().status.canUseAiSmartEntry;
    final accentColor = _getTabColor(context, activeTab);

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLockedQuickEntry(
            context,
            quickEntry.quickEntry,
            accentColor,
            canUseAiSmartEntry,
          ),
          if (canUseAiSmartEntry && suggestionSource != null)
            TransactionSmartSuggestionChip(
              key: ObjectKey(suggestionSource),
              source: suggestionSource,
              accentColor: accentColor,
            ),
        ],
      ),
    );
  }

  /// AI smart entry is locked below LV3 (no VIP), and until the user agrees to
  /// share data with Gemini: every input sends data, so there is no AI entry
  /// without consent. Tapping the consent lock asks for it.
  Widget _buildLockedQuickEntry(
    BuildContext context,
    QuickEntrySession controller,
    Color accentColor,
    bool canUseAiSmartEntry,
  ) {
    final section = _buildQuickEntrySection(context, controller, accentColor);
    if (!canUseAiSmartEntry) {
      return CcLockOverlay(hasLocked: true, child: section);
    }

    final aiPreferences = controller.handler.parser.aiPreferences;
    return ValueListenableBuilder<bool?>(
      valueListenable: aiPreferences.geminiEnabledListenable,
      builder: (context, hasGeminiEnabled, child) => CcLockOverlay(
        // Unknown (still loading) is not shown as locked, so the lock never
        // flashes for a user who already agreed; the parsers check again.
        hasLocked: hasGeminiEnabled == false,
        semanticLabel: el.tr(PrjLocaleKeys.profile_ai_consent_title),
        onLockedTap: () => AiConsentSheet.ensure(context, aiPreferences),
        child: child!,
      ),
      child: section,
    );
  }

  Widget _buildQuickEntrySection(
    BuildContext context,
    QuickEntrySession controller,
    Color accentColor,
  ) {
    final suggestion = controller.quickEntrySuggestion.value;
    final errorKey = controller.quickEntryErrorKey.value;
    return QuickEntrySection(
      controller: controller.quickEntryController,
      hasParsing: controller.hasParsingQuickEntry.value,
      hasListening: controller.hasListeningQuickEntry.value,
      suggestionLabel: suggestion != null
          ? controller.quickEntryResultLabel(suggestion)
          : null,
      hasCategoryMissing: controller.hasQuickEntryCategoryInvalid,
      errorText: errorKey != null ? el.tr(errorKey) : null,
      activeColor: accentColor,
      onSubmitted: (_) => controller.submitQuickEntry(context),
      onMicTap: () => controller.toggleVoiceQuickEntry(context),
      // Camera icon temporarily disabled in QuickEntrySection due to crashes.
      onScanTap: () => _pickReceiptSource(context, controller),
      onApplySuggestion: () {
        if (suggestion != null) controller.applyQuickEntryParse(suggestion);
      },
      onDismissSuggestion: controller.dismissQuickEntrySuggestion,
      onClear: () {
        controller.dismissQuickEntrySuggestion();
        controller.hasParsingQuickEntry.value = false;
      },
    );
  }

  Future<void> _pickReceiptSource(
    BuildContext context,
    QuickEntrySession controller,
  ) async {
    if (!controller.beginQuickEntryImage()) return;
    final fromCamera = await ReceiptSourceSheet.show(context);
    if (fromCamera == null) {
      controller.cancelQuickEntryImage();
      return;
    }
    if (!context.mounted) return;
    if (!fromCamera && controller is QuickEntryBatchSession) {
      controller.submitQuickEntryFromGallery(context);
      return;
    }
    controller.submitQuickEntryFromImage(context, fromCamera: fromCamera);
  }

  static Color _getTabColor(BuildContext context, TransactionTabKind tab) {
    return switch (tab) {
      TransactionTabKind.expense => context.expenseAccent,
      TransactionTabKind.income => context.incomeAccent,
      TransactionTabKind.investment => context.investmentAccent,
      TransactionTabKind.borrow => context.borrowAccent,
      TransactionTabKind.lend => context.lendAccent,
    };
  }
}
