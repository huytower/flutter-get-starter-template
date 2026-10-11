import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/report_controller.dart';
import 'trend_card.dart';

class ReportInvestmentSection extends StatelessWidget {
  const ReportInvestmentSection({super.key, required this.controller});

  final ReportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.investmentTrend.value;
      if (!controller.userLevel.status.value.canUseInvestment ||
          data == null ||
          (data.totalIncome == 0 && data.totalExpense == 0)) {
        return const SizedBox.shrink();
      }

      final filter = controller.filterType.value;
      if (filter != ReportFilterType.all &&
          filter != ReportFilterType.investment) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CcSpaceLG(),
          TrendCard(
            title: el.tr(CcLocaleKeys.report_investment_contributed),
            amount: data.totalExpense,
            points: data.points,
            color: context.ccColorScheme.investment,
            range: controller.range.value,
            isIncome: false,
            icon: Icons.eco,
          ),
          const CcSpaceLG(),
          TrendCard(
            title: el.tr(CcLocaleKeys.report_investment_returned),
            amount: data.totalIncome,
            points: data.points,
            color: context.ccColorScheme.investmentSecondary,
            range: controller.range.value,
            isIncome: true,
            icon: Icons.auto_graph_rounded,
          ),
        ],
      );
    });
  }
}
