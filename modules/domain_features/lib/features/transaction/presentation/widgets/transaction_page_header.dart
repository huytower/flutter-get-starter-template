import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
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
    // Fill the parent height (constrained by TransactionPage). No hardcoded
    // base height — the header keeps a correct responsive ratio across screen
    // sizes via flex-based sections instead of a width-scaled respDim() magic
    // number.
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.respDim(16)),
          bottomRight: Radius.circular(context.respDim(16)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _buildHeroBackground(context),
          _buildHeroForeground(context),
        ],
      ),
    );
  }

  Widget _buildHeroBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = isDark
        ? 'assets/bg/bg_header_dark.webp'
        : 'assets/bg/bg_header_light.webp';
    return Positioned.fill(child: Image.asset(assetPath, fit: BoxFit.cover));
  }

  Widget _buildHeroForeground(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: context.respDim(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (MediaQuery.of(context).padding.top > 0)
            SizedBox(height: MediaQuery.of(context).padding.top),

          // Using Spacers with flex factors to distribute space proportionally.
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
              child: buildBanner(context),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  CcListBannerSmall buildBanner(BuildContext context) {
    return CcListBannerSmall(
      title: el.tr(
        CcLocaleKeys.transaction_claims_in_progress,
        namedArgs: {'count': '2'},
      ),
      description: el.tr(CcLocaleKeys.profile_birth_year_task_desc),
      accentColor: context.ccColorScheme.primary,
      onTap: () {},
      icon: CcClipboardChecklistIcon(
        size: context.respDim(40) * 0.8,
        bodyColor: context.ccColorScheme.onPrimary.withValues(alpha: 0.85),
        clipColor: context.ccColorScheme.onPrimary,
        markColor: context.ccColorScheme.primary,
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
      final activeColor = _getTabColor(context, selectedIndex);

      return CcIconButton.bouncing(
        onTap: onSubmit ?? () {},
        bgColor: Colors.white.withOpacity(0.15),
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

  Color _getTabColor(BuildContext context, int index) {
    return switch (index) {
      0 => context.ccColorScheme.error,
      2 => context.ccColorScheme.secondary,
      _ => PrjColors.success,
    };
  }
}
