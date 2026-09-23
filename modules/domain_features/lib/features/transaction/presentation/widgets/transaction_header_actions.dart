import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../get_x/transaction_controller.dart';

class TransactionHeaderActions extends StatelessWidget {
  const TransactionHeaderActions({
    super.key,
    required this.controller,
    this.onSubmit,
    this.onOpenReport,
  });

  final TransactionController controller;
  final VoidCallback? onSubmit;
  final VoidCallback? onOpenReport;

  @override
  Widget build(BuildContext context) {
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
