import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../guideline/export_guideline.dart';
import '../../../profile/user_level/presentation/get_x/user_level_controller.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/quick_entry_mixin.dart';
import '../get_x/transaction_controller.dart';
import 'quick_entry_section.dart';
import 'receipt_source_sheet.dart';
import 'transaction_smart_suggestion_chip.dart';

class TransactionHeaderBanner extends StatelessWidget {
  const TransactionHeaderBanner({
    super.key,
    required this.controller,
    required this.guideline,
    this.expenseFormController,
  });

  final TransactionController controller;
  final GuidelineController guideline;
  final ExpenseFormController? expenseFormController;

  @override
  Widget build(BuildContext context) {
    return Obx(() => _buildContent(context));
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
          guideline.isBannerHidden.value = true;
        }
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          guideline.isBannerHidden.value = false;
        }
      },
      child: const TransactionGuidelineBanner(shouldHideDescription: false),
    );
  }

  QuickEntryMixin? _quickEntryControllerFor(TransactionTabKind tab) {
    return (tab == TransactionTabKind.expense && expenseFormController != null)
        ? expenseFormController
        : controller.getQuickEntryControllerForTab(tab);
  }

  Widget _buildAiComponents(
    BuildContext context,
    TransactionTabKind activeTab,
  ) {
    final quickEntry = _quickEntryControllerFor(activeTab);

    if (quickEntry == null) return const SizedBox.shrink();

    final canUseAiSmartEntry =
        getIt<UserLevelController>().status.value.canUseAiSmartEntry;
    final accentColor = _getTabColor(context, activeTab);
    final isLocked = !canUseAiSmartEntry;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildQuickEntrySection(context, quickEntry, accentColor, isLocked),
              if (isLocked) _buildLockOverlay(context),
            ],
          ),
          if (expenseFormController != null) ...[
            TransactionSmartSuggestionChip(
              expenseFormController: expenseFormController!,
              accentColor: accentColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickEntrySection(
    BuildContext context,
    QuickEntryMixin controller,
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
      onScanTap: () => _pickReceiptSource(context, controller),
      onApplySuggestion: () {
        if (suggestion != null) controller.applyQuickEntryParse(suggestion);
      },
      onDismissSuggestion: controller.dismissQuickEntrySuggestion,
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
          color: scheme.surface.withOpacity(0.4),
          borderRadius: context.brLg,
        ),
child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(context.respDim(6)),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.onSurfaceVariant.withOpacity(0.2),
                      width: context.respDim(1),
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: context.respIconSize(baseSize: 18),
                    color: scheme.onSurfaceVariant.withOpacity(0.85),
                  ),
                ),
                const CcSpaceXS(),
                CcText(
                  el.tr(CcLocaleKeys.level_lock_unlock_free_at_lv3),
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.9),
                    fontWeight: CcTypographyParams.bold,
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
    QuickEntryMixin controller,
  ) async {
    if (!controller.beginQuickEntryImage()) return;
    final fromCamera = await ReceiptSourceSheet.show(context);
    if (fromCamera == null) {
      controller.cancelQuickEntryImage();
      return;
    }
    if (!context.mounted) return;
    controller.submitQuickEntryFromImage(context, fromCamera: fromCamera);
  }

  static Color _getTabColor(BuildContext context, TransactionTabKind tab) {
    return switch (tab) {
      TransactionTabKind.expense => context.ccColorScheme.error,
      TransactionTabKind.income => PrjColors.success,
      TransactionTabKind.investment => context.ccColorScheme.investment,
      TransactionTabKind.liability => context.ccColorScheme.liability,
      TransactionTabKind.lend => context.ccColorScheme.liability,
    };
  }
}
