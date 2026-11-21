import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/features/transaction/presentation/widgets/transaction_smart_suggestion_chip.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/di/di.dart';
import '../../../guideline/export_guideline.dart';
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

  bool _isSupportedLanguageAndCurrency(BuildContext context) {
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
    final isGuidelineComplete = remainingSteps == 0;

    final tabs = controller.visibleTabs;
    final activeTabIndex = controller.selectedTabIndex.value;
    final activeTab = tabs[activeTabIndex.clamp(0, tabs.length - 1)];

    if (isGuidelineComplete) {
      return _buildAiComponents(context, activeTab);
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          guideline.isBannerHidden = true;
        }
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          guideline.isBannerHidden = false;
        }
      },
      child: TransactionGuidelineBanner(
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
    if (!_isSupportedLanguageAndCurrency(context)) {
      return const SizedBox.shrink();
    }

    final quickEntry = _quickEntryControllerFor(activeTab);

    if (quickEntry == null) return const SizedBox.shrink();

    final suggestionSource = _suggestionSourceFor(activeTab);

    final canUseAiSmartEntry =
        getIt<UserLevelProvider>().status.canUseAiSmartEntry;
    final accentColor = _getTabColor(context, activeTab);
    final isLocked = !canUseAiSmartEntry;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildQuickEntrySection(
                context,
                quickEntry.quickEntry,
                accentColor,
                isLocked,
              ),
              if (isLocked) _buildLockOverlay(context),
            ],
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

  Widget _buildQuickEntrySection(
    BuildContext context,
    QuickEntrySession controller,
    Color accentColor,
    bool isLocked,
  ) {
    final suggestion = controller.quickEntrySuggestion.value;
    final errorKey = controller.quickEntryErrorKey.value;
    return QuickEntrySection(
      controller: controller.quickEntryController,
      isParsing: controller.isParsingQuickEntry.value,
      isListening: controller.isListeningQuickEntry.value,
      suggestionLabel: suggestion != null
          ? controller.quickEntryResultLabel(suggestion)
          : null,
      isCategoryMissing: controller.isQuickEntryCategoryInvalid,
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
      aiPreferences: controller.handler.parser.aiPreferences,
      onClear: () {
        controller.dismissQuickEntrySuggestion();
        controller.isParsingQuickEntry.value = false;
      },
      isLocked: isLocked,
    );
  }

  Widget _buildLockOverlay(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withOpacity(0.3),
          borderRadius: context.brLg,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.respDim(32),
                height: context.respDim(32),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.onSurfaceVariant.withOpacity(0.1),
                    width: context.respDim(1.5),
                  ),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: context.respIconSize(baseSize: 16),
                  color: scheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
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
      TransactionTabKind.liability => context.borrowAccent,
      TransactionTabKind.lend => context.lendAccent,
    };
  }
}
