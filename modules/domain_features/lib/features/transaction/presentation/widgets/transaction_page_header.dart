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
    final topPadding = MediaQuery.of(context).padding.top;
    // Header height is screen-type aware (not width-scaled) so it stays
    // appropriate on tablets instead of ballooning with screen width.
    final baseHeight = CcResponsiveHelper.getValue(
      context: context,
      mobile: 200.0,
      tablet: 220.0,
      desktop: 240.0,
    );
    final headerHeight = baseHeight + topPadding;

    return Container(
      height: headerHeight,
      width: double.infinity,
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
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      bottom: context.respDim(16),
      child: CcSymmetricPadding(
        horizontal: CcPaddingParams.PAGE_MD,
        child: Column(
          children: [
            const CcSpaceSM(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeaderTitleSection(context),
                _buildHeaderActions(context),
              ],
            ),
            const CcSpaceSM(), // nice for small phone
            buildBanner(context),
          ],
        ),
      ),
    );
  }

  CcFrostedBanner buildBanner(BuildContext context) {
    return CcFrostedBanner(
      title: el.tr(
        CcLocaleKeys.transaction_claims_in_progress,
        namedArgs: {'count': '2'},
      ),
      description: el.tr(CcLocaleKeys.profile_birth_year_task_desc),
      accentColor: context.ccColorScheme.primary,
      onTap: () {},
      icon: CcClipboardChecklistIcon(
        size: context.respDim(44) * 0.8,
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
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[...previousChildren, ?currentChild],
            );
          },
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
