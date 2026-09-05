import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/money_format_helper.dart';
import '../../../guideline/export_guideline.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/quick_entry_mixin.dart';
import '../get_x/transaction_controller.dart';
import 'quick_entry_section.dart';
import 'receipt_source_sheet.dart';
import 'transaction_wallet_summary.dart';

class TransactionPageHeader extends StatelessWidget {
  const TransactionPageHeader({
    super.key,
    required this.controller,
    this.onOpenNotification,
    this.onOpenReport,
    this.onSubmit,
    this.expenseFormController,
  });

  final TransactionController controller;
  final VoidCallback? onOpenNotification;
  final VoidCallback? onOpenReport;
  final VoidCallback? onSubmit;
  final ExpenseFormController? expenseFormController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/bg/bg_header_dark.webp'
        : 'assets/bg/bg_header_light.webp';

    // We calculate the overlap locally to match TransactionPage's logic.
    final overlap = context.respDim(64) / 2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(context.respDim(16)),
            bottomRight: Radius.circular(context.respDim(16)),
          ),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(bottom: overlap),
          child: _buildHeroForeground(context),
        ),
      ),
    );
  }

  Widget _buildHeroForeground(BuildContext context) {
    // Inject GuidelineController
    final guideline = Get.find<GuidelineController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (MediaQuery.of(context).padding.top > 0)
          SizedBox(height: MediaQuery.of(context).padding.top),

        const CcSpaceMD(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_MD,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeaderTitleSection(context),
              _buildHeaderActions(context),
            ],
          ),
        ),
        const CcSpaceXS(),
        CcSymmetricPadding(
          horizontal: CcPaddingParams.PAGE_MD,
          child: Obx(() => buildBanner(context, guideline)),
        ),
      ],
    );
  }

  Widget buildBanner(BuildContext context, GuidelineController guideline) {
    final activeId = guideline.currentTaskId;
    final isGuidelineComplete = activeId == null;

    final tabs = controller.visibleTabs;
    final activeTabIndex = controller.selectedTabIndex.value;
    final activeTab = tabs[activeTabIndex.clamp(0, tabs.length - 1)];

    if (isGuidelineComplete) {
      return _buildAiComponents(context, activeTab);
    }

    // Otherwise show the guideline banner
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Detect left-to-right swipe (positive velocity)
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          guideline.isBannerHidden.value = true;
        }
        // Optional: Right-to-left to show it back
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          guideline.isBannerHidden.value = false;
        }
      },
      child: const TransactionGuidelineBanner(shouldHideDescription: false),
    );
  }

  QuickEntryMixin? _quickEntryControllerFor(TransactionTabKind tab) {
    if (tab == TransactionTabKind.expense && expenseFormController != null) {
      return expenseFormController;
    }
    return controller.getQuickEntryControllerForTab(tab);
  }

  Widget _buildAiComponents(
    BuildContext context,
    TransactionTabKind activeTab,
  ) {
    final quickEntry = _quickEntryControllerFor(activeTab);
    if (quickEntry == null) return const SizedBox.shrink();

    final suggestionLabel =
        activeTab == TransactionTabKind.expense && expenseFormController != null
        ? _suggestionLabel(expenseFormController!)
        : null;
    final canUseAiSmartEntry =
        getIt<UserLevelController>().status.value.canUseAiSmartEntry;
    final accentColor = _getTabColor(context, activeTab);

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canUseAiSmartEntry)
            _buildQuickEntrySection(context, quickEntry, accentColor),
          if (suggestionLabel != null) ...[
            CcSuggestionChip(
              label: suggestionLabel,
              accentColor: accentColor,
              icon: expenseFormController?.merchantMatchSuggestion.value != null
                  ? Icons.auto_awesome
                  : expenseFormController?.billMatchSuggestion.value != null
                  ? Icons.event_repeat
                  : Icons.place,
              onTap: () => _applySuggestion(expenseFormController!),
              onDismiss: () => _dismissSuggestion(expenseFormController!),
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
    controller.submitQuickEntryFromImage(context, fromCamera: fromCamera);
  }

  String? _suggestionLabel(ExpenseFormController controller) {
    final merchantMatch = controller.merchantMatchSuggestion.value;
    if (merchantMatch != null) {
      return el.tr(
        CcLocaleKeys.transaction_merchant_match_hint,
        namedArgs: {'label': _formatSuggestionLabel(merchantMatch)},
      );
    }
    final billMatch = controller.billMatchSuggestion.value;
    if (billMatch != null) {
      return el.tr(
        CcLocaleKeys.transaction_bill_match_hint,
        namedArgs: {'label': _formatSuggestionLabel(billMatch)},
      );
    }
    final locationMatch = controller.locationMatchSuggestion.value;
    if (locationMatch != null) {
      return el.tr(
        CcLocaleKeys.transaction_location_match_hint,
        namedArgs: {'label': _formatSuggestionLabel(locationMatch)},
      );
    }
    return null;
  }

  String _formatSuggestionLabel(TransactionEntity match) =>
      '${match.category} · ${formatVndShort(match.amount)}đ';

  void _applySuggestion(ExpenseFormController controller) {
    final merchantMatch = controller.merchantMatchSuggestion.value;
    if (merchantMatch != null) {
      controller.applyMerchantMatch(merchantMatch);
      return;
    }
    final billMatch = controller.billMatchSuggestion.value;
    if (billMatch != null) {
      controller.applyBillMatch(billMatch);
      return;
    }
    final locationMatch = controller.locationMatchSuggestion.value;
    if (locationMatch != null) controller.applyLocationMatch(locationMatch);
  }

  void _dismissSuggestion(ExpenseFormController controller) {
    if (controller.merchantMatchSuggestion.value != null) {
      controller.dismissMerchantMatch();
    } else if (controller.billMatchSuggestion.value != null) {
      controller.dismissBillMatch();
    } else {
      controller.dismissLocationMatch();
    }
  }

  Widget _buildAutoSaveMessage(
    BuildContext context,
    int countdown,
    QuickEntryMixin quickEntry,
  ) {
    return Row(
      key: const ValueKey('auto_save_message'),
      children: [
        Icon(
          Icons.auto_awesome,
          size: context.respIconSize(baseSize: 18),
          color: context.ccColorScheme.primary,
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            el.tr(
              CcLocaleKeys.transaction_auto_save_countdown,
              namedArgs: {'countdown': countdown.toString()},
            ),
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              color: context.ccColorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        CcIconButton.bouncing(
          icon: Icon(
            Icons.close_rounded,
            size: context.respIconSize(baseSize: 16),
            color: context.ccColorScheme.onPrimary.withOpacity(0.8),
          ),
          onTap: quickEntry.cancelAutoSaveManually,
          width: context.respDim(24),
          height: context.respDim(24),
        ),
      ],
    );
  }

  Widget _buildHeaderTitleSection(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final bool showSummary = controller.showWalletSummaryTemporarily.value;

        final tabs = controller.visibleTabs;
        final activeTab =
            tabs[controller.selectedTabIndex.value.clamp(0, tabs.length - 1)];
        final quickEntry = _quickEntryControllerFor(activeTab);
        final countdown = quickEntry?.autoSaveCountdown.value ?? 0;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: showSummary
              ? const TransactionWalletSummary(key: ValueKey('wallet_summary'))
              : (countdown > 0 && quickEntry != null
                    ? _buildAutoSaveMessage(context, countdown, quickEntry)
                    : _buildPageTitle(context)),
        );
      }),
    );
  }

  Widget _buildPageTitle(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.transaction_title),
      key: const ValueKey('transaction_title'),
      textStyle: context.ccTextTheme.titleLarge?.copyWith(
        color: context.ccColorScheme.onPrimary,
        fontWeight: CcTypographyParams.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSubmitButton(context),
        const CcSpaceXS(),
        _buildReportButton(context),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedTabIndex.value;
      final tabs = controller.visibleTabs;
      if (selectedIndex < 0 || selectedIndex >= tabs.length) {
        return const SizedBox.shrink();
      }
      final tabKind = tabs[selectedIndex];
      final activeColor = _getTabColor(context, tabKind);

      return CcIconButton.bouncing(
        onTap: onSubmit ?? () {},
        bgColor: context.ccColorScheme.onPrimary.withAlpha(10),
        height: context.respDim(30),
        width: context.respDim(30),
        icon: Icon(
          Icons.check_rounded,
          size: context.respIconSize(baseSize: 22),
          color: activeColor,
        ),
      );
    });
  }

  Widget _buildReportButton(BuildContext context) {
    return CcIconButton.bouncing(
      onTap: onOpenReport ?? () {},
      icon: Icon(
        Icons.bar_chart_rounded,
        size: context.respIconSize(baseSize: 28),
        color: context.ccColorScheme.onPrimary,
      ),
      tooltip: el.tr(CcLocaleKeys.report_title),
    );
  }

  Color _getTabColor(BuildContext context, TransactionTabKind tab) {
    return switch (tab) {
      TransactionTabKind.expense => context.ccColorScheme.error,
      TransactionTabKind.income => PrjColors.success,
      TransactionTabKind.investment => context.ccColorScheme.investment,
      TransactionTabKind.liability => context.ccColorScheme.debtLoan,
      TransactionTabKind.lend => context.ccColorScheme.debtLoan,
    };
  }
}
