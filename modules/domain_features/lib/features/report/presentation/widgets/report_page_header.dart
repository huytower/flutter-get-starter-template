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
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = context.respDim(200) + topPadding;

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
        children: [_buildHeroBackground(), _buildHeroForeground(context)],
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Positioned.fill(
      child: Image.asset('assets/bg/bg_header.webp', fit: BoxFit.cover),
    );
  }

  Widget _buildHeroForeground(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(context),
            const CcSpaceSM(),
            _buildRunwaySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBackButton(context),
          const CcSpaceXS(),
          _buildHeaderTitleSection(context),
        ],
      ),
    );
  }

  Widget _buildHeaderTitleSection(BuildContext context) {
    return Expanded(child: _buildPageTitle(context));
  }

  Widget _buildPageTitle(BuildContext context) {
    return CcText(
      title,
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
        color: context.ccColorScheme.onPrimary,
        fontWeight: CcTypographyParams.bold,
        fontSize: context.respFontSize(16),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRunwaySection(BuildContext context) {
    return Obx(() {
      final runway = controller.runway.value;
      if (runway == null) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        ),
        child: FinancialRunwayWidget(runway: runway),
      );
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
