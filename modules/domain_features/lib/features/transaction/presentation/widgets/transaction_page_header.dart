import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/features/guideline/guideline_controller.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../get_x/transaction_controller.dart';
import 'transaction_wallet_summary.dart';

class TransactionPageHeader extends StatelessWidget {
  const TransactionPageHeader({
    super.key,
    required this.controller,
    this.onOpenNotification,
    this.onOpenReport,
    this.onSubmit,
  });

  final TransactionController controller;
  final VoidCallback? onOpenNotification;
  final VoidCallback? onOpenReport;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/bg/bg_header_dark.webp'
        : 'assets/bg/bg_header_light.webp';

    // We calculate the overlap locally to match TransactionPage's logic.
    final overlap = context.respDim(60) / 2;

    // Optimized approach: Instead of using a Stack to layer background and
    // foreground, we move the background image into the Container's decoration.
    // This reduces the depth of the widget tree and simplifies the layout
    // phase by using a single flat child.
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.respDim(16)),
          bottomRight: Radius.circular(context.respDim(16)),
        ),
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(bottom: overlap),
        child: _buildHeroForeground(context),
      ),
    );
  }

  Widget _buildHeroForeground(BuildContext context) {
    // Inject GuidelineController
    final guideline = Get.find<GuidelineController>();

    // Content is now a direct child of the Container (with bottom overlap padding).
    // We use a flex Column to distribute space proportionally.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (MediaQuery.of(context).padding.top > 0)
          SizedBox(height: MediaQuery.of(context).padding.top),

        const Spacer(flex: 1),
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
        const Spacer(flex: 1),

        // Use Flexible to allow the banner to take its needed space
        // without overflowing the Column's fixed height.
        Flexible(
          flex: 12,
          child: CcSymmetricPadding(
            horizontal: CcPaddingParams.PAGE_MD,
            child: Obx(() => buildBanner(context, guideline)),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget buildBanner(BuildContext context, GuidelineController guideline) {
    final activeId = guideline.currentTaskId;
    final accentColor = guideline.currentColor;

    return CcListBannerSmall(
      title: guideline.bannerTitle,
      description: guideline.bannerDescription,
      accentColor: accentColor,
      onTap: () {
        // Trigger bounce animation on the tab bar badge
        guideline.triggerBounce();
      },
      icon: CcClipboardChecklistIcon(
        size: context.respDim(40) * 0.8,
        bodyColor: context.ccColorScheme.onPrimary.withValues(alpha: 0.85),
        clipColor: context.ccColorScheme.onPrimary,
        markColor: accentColor,
      ),
    );
  }

  Widget _buildHeaderTitleSection(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final bool showSummary = controller.showWalletSummaryTemporarily.value;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          // Use the default layout builder. A custom Stack here conflicts with
          // the Expanded (which lives under the header's outer Stack), causing
          // a "Competing ParentDataWidgets" assertion during transitions.
          child: showSummary
              ? const TransactionWalletSummary(key: ValueKey('wallet_summary'))
              : _buildPageTitle(context),
        );
      }),
    );
  }

  Widget _buildPageTitle(BuildContext context) {
    return CcText(
      el.tr(CcLocaleKeys.transaction_title),
      key: const ValueKey('transaction_title'),
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
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
      final tabKind = controller.visibleTabs[selectedIndex];
      final activeColor = _getTabColor(context, tabKind);

      return CcIconButton.bouncing(
        onTap: onSubmit ?? () {},
        bgColor: activeColor,
        height: context.respDim(40),
        width: context.respDim(40),
        icon: Icon(
          Icons.check_rounded,
          size: context.respIconSize(baseSize: 22),
          color: context.ccColorScheme.onPrimary,
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
      TransactionTabKind.investment => PrjColors.investment,
      TransactionTabKind.debtLoan => PrjColors.debtLoan,
    };
  }
}
