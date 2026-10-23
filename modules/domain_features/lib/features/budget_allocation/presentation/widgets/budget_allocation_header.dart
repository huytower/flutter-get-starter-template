import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../report/presentation/widgets/report_daily_detail_shortcut.dart';
import '../get_x/budget_allocation_controller.dart';

class BudgetAllocationHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const BudgetAllocationHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetAllocationController>();

    return buildDomainGradientAppBar(
      context,
      title: CcText(
        el.tr(CcLocaleKeys.nav_budget_allocation),
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
        ),
      ),
      actions: [
        CcBouncing(
          onTap: () => controller.navigateToReconcile(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CcText(
                'Kiểm toán',
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
}
