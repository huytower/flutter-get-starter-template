import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
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
    // We calculate the overlap locally to match ReportPage's logic.
    final overlap = context.respDim(60) / 2;

    // We use a flex-based layout within the bounded height (30% mobile / 25% tablet).
    // Positioned(bottom: overlap) ensures content never bleeds into the area
    // covered by the TabBar, eliminating overlap conflicts on small phones.
    //
    // Fixed "Cannot hit test a render box with no size" error:
    // This Positioned widget provides explicit constraints to the foreground
    // Column, ensuring it always has a valid size for hit testing and layout.
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: overlap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (MediaQuery.of(context).padding.top > 0)
            SizedBox(height: MediaQuery.of(context).padding.top),

          // Using Spacers with flex factors to distribute space proportionally.
          const Spacer(flex: 1),
          _buildTitleRow(context),
          const Spacer(flex: 1),

          Flexible(
            flex: 15,
            child: CcSymmetricPadding(
              horizontal: CcPaddingParams.PAGE_XS,
              child: _buildRunwaySection(context),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
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
        ],
      ),
    );
  }

  Widget _buildPageTitle(BuildContext context) {
    return CcText(
      title,
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
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
    return CcIconButton.bouncing(
      onTap: onBackPressed,
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: context.ccColorScheme.onPrimary,
        size: context.respIconSize(baseSize: 24),
      ),
    );
  }
}
