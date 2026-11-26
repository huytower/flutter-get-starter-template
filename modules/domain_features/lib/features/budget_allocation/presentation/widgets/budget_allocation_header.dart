import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../../../report/presentation/widgets/report_daily_detail_shortcut.dart';

/// [onReconcile] opens the reconciliation page (through its entry guard).
PreferredSizeWidget buildBudgetAllocationHeader(
  BuildContext context, {
  required VoidCallback onReconcile,
}) {
  return CcGradientAppBar.create(
    context,
    title: CcText(
      el.tr(PrjLocaleKeys.nav_budget_allocation),
      textStyle: context.ccTextTheme.titleMedium?.copyWith(
        color: context.ccColorScheme.onPrimary,
        fontWeight: CcTypographyParams.bold,
      ),
    ),
    actions: [
      CcBouncing(
        onTap: onReconcile,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CcText(
              el.tr(PrjLocaleKeys.reconciliation_title),
              textStyle: context.ccTextTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const CcSpaceXS(),
            Icon(
              Icons.fact_check_outlined,
              color: context.ccColorScheme.onPrimary,
              size: context.respIconSize(baseSize: 20),
            ),
          ],
        ),
      ),
      const CcSpaceSM(),
      const ReportDailyDetailShortcut(color: Colors.white),
    ],
  );
}

class BudgetAllocationHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const BudgetAllocationHeader({super.key, required this.onReconcile});

  final VoidCallback onReconcile;

  @override
  Size get preferredSize {
    final context = Get.context;
    if (context == null) return const Size.fromHeight(kToolbarHeight);
    final topPadding = MediaQuery.of(context).padding.top;
    return Size.fromHeight(context.respDim(64) + topPadding);
  }

  @override
  Widget build(BuildContext context) {
    return buildBudgetAllocationHeader(context, onReconcile: onReconcile);
  }
}
