import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../get_x/transaction_controller.dart';

class TransactionTabBar extends StatelessWidget {
  const TransactionTabBar({super.key, required this.controller});

  final TransactionController controller;

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
    final selectedIndex = controller.selectedTabIndex.value;
    final activeColor = _getTabColor(context, selectedIndex);

    return TabBar(
      onTap: controller.setTabIndex,
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
        Tab(text: el.tr(CcLocaleKeys.transaction_expense_slip)),
        Tab(text: el.tr(CcLocaleKeys.transaction_income_slip)),
        Tab(text: el.tr(CcLocaleKeys.transaction_record_transfer)),
      ],
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
