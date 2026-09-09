import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../get_x/report_controller.dart';
import 'financial_runway_widget.dart';

class ReportPageHeader extends StatelessWidget {
  const ReportPageHeader({
    super.key,
    required this.controller,
    required this.title,
    required this.onBackPressed,
  });

  final ReportController controller;
  final String title;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    // Fill the parent height (already constrained by ReportPage). No hardcoded
    // base height — the header keeps a correct responsive ratio across screen
    // sizes via flex-based sections instead of a width-scaled respDim() magic
    // number. The Column children resolve against this bounded height.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Container(
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
    // We calculate the overlap locally to match ReportPage's logic.
    final overlap = context.respDim(60) / 2;

    // We use a flex-based layout within the bounded height (30% mobile / 25% tablet).
    // Positioned(bottom: overlap) ensures content never bleeds into the area
    // covered by the TabBar, eliminating overlap conflicts on small phones.
    //
    // Fixed "Cannot hit test a render box with no size" error:
    // This Positioned widget provides explicit constraints to the foreground
    // Column, ensuring it always has a valid size for hit testing and layout.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (MediaQuery.of(context).padding.top > 0)
          SizedBox(height: MediaQuery.of(context).padding.top),

        // Using Spacers with flex factors to distribute space proportionally.
        const Spacer(flex: 1),
        _buildTitleRow(context),
        const Spacer(flex: 1),

        Flexible(
          flex: 20,
          child: CcSymmetricPadding(
            horizontal: CcPaddingParams.PAGE_XS,
            child: _buildRunwaySection(context),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.PAGE_XS,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBackButton(context),
          const CcSpaceXS(),
          Expanded(child: _buildPageTitle(context)),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  /// Combined filter button for both wallet and transaction type.
  Widget _buildFilterButton(BuildContext context) {
    return Obx(() {
      final walletName = controller.filterWalletName.value;
      final type = controller.filterType.value;

      final isWalletActive = walletName != null;
      final isTypeActive = type != ReportFilterType.all;
      final isActive = isWalletActive || isTypeActive;

      String label;
      if (isWalletActive && isTypeActive) {
        label = '$walletName · ${_typeLabel(type)}';
      } else if (isWalletActive) {
        label = walletName;
      } else if (isTypeActive) {
        label = _typeLabel(type);
      } else {
        label = el.tr(CcLocaleKeys.report_filter_all_wallets);
      }

      final scheme = context.ccColorScheme;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Tooltip(
        message: el.tr(CcLocaleKeys.report_filter_by_wallet),
        child: CcBouncing(
          borderRadius: BorderRadius.circular(context.respDim(8)),
          onTap: () => controller.openFilterPicker(context),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
              vertical: context.respPadding(CcPaddingParams.SPACE_XS),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withValues(alpha: 0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.respDim(100)),
                    child: CcText(
                      label,
                      align: Alignment.centerRight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                        fontWeight: isActive
                            ? CcTypographyParams.bold
                            : CcTypographyParams.regular,
                      ),
                    ),
                  ),
                  const CcSpaceXS(),
                  Icon(
                    isActive
                        ? Icons.filter_alt_rounded
                        : Icons.filter_alt_outlined,
                    color: scheme.onPrimary,
                    size: context.respIconSize(baseSize: 22),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  String _typeLabel(ReportFilterType type) {
    switch (type) {
      case ReportFilterType.all:
        return el.tr(CcLocaleKeys.report_filter_all_types);
      case ReportFilterType.expense:
        return el.tr(CcLocaleKeys.common_expense);
      case ReportFilterType.income:
        return el.tr(CcLocaleKeys.common_income);
      case ReportFilterType.investment:
        return el.tr(CcLocaleKeys.transaction_investment);
      case ReportFilterType.liability:
        return el.tr(CcLocaleKeys.liability_title);
      case ReportFilterType.lend:
        return el.tr(CcLocaleKeys.liability_lend);
    }
  }

  Widget _buildPageTitle(BuildContext context) {
    return CcText(
      title,
      textStyle: context.ccTextTheme.titleLarge?.copyWith(
        color: context.ccColorScheme.onPrimary,
        fontWeight: CcTypographyParams.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRunwaySection(BuildContext context) {
    return Obx(() {
      final runway = controller.runway.value;
      if (runway == null) return const SizedBox.shrink();

      return FinancialRunwayWidget(runway: runway, showChevron: false);
    });
  }

  Widget _buildBackButton(BuildContext context) {
    return Obx(
      () => CcIconButton.bouncing(
        onTap: onBackPressed,
        icon: Icon(
          controller.isEditMode.value
              ? Icons.close_rounded
              : Icons.arrow_back_ios_new_rounded,
          color: context.ccColorScheme.onPrimary,
          size: context.respIconSize(baseSize: 24),
        ),
      ),
    );
  }
}
