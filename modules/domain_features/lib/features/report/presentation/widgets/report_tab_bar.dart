import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../domain/report_range.dart';
import '../get_x/report_controller.dart';

class ReportTabBar extends StatelessWidget {
  const ReportTabBar({super.key, required this.controller});

  final ReportController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      height: context.respDim(45),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.respDim(20)),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withOpacity(0.12),
            blurRadius: context.respDim(12),
            offset: Offset(0, context.respDim(6)),
          ),
        ],
      ),
      padding: EdgeInsets.all(context.respDim(4)),
      child: Obx(() => _buildActualTabBar(context, scheme)),
    );
  }

  Widget _buildActualTabBar(BuildContext context, ColorScheme scheme) {
    final selectedIndex = controller.range.value.index;
    final activeColor = _getTabColor(context, selectedIndex);

    return TabBar(
      onTap: (index) => controller.selectRange(ReportRange.values[index]),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      indicator: BoxDecoration(
        color: activeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(context.respDim(16)),
      ),
      labelColor: activeColor,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: context.ccTextTheme.labelMedium?.copyWith(
        fontWeight: CcTypographyParams.bold,
        fontSize: context.respFontSize(CcTypographyParams.labelMedium),
      ),
      labelPadding: EdgeInsets.zero,
      tabs: [
        Tab(text: el.tr(CcLocaleKeys.report_weekly)),
        Tab(text: el.tr(CcLocaleKeys.report_three_months)),
        Tab(text: el.tr(CcLocaleKeys.report_yearly)),
      ],
    );
  }

  Color _getTabColor(BuildContext context, int index) {
    return switch (index) {
      0 => context.ccColorScheme.error,
      1 => context.ccColorScheme.primary,
      _ => PrjColors.success,
    };
  }
}
