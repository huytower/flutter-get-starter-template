import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_x/report_controller.dart';
import 'trend_card.dart';

class ReportLiabilitySection extends StatelessWidget {
  const ReportLiabilitySection({super.key, required this.controller});

  final ReportController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.liabilityTrend.value;
      if (!controller.userLevel.status.value.canUseLiability ||
          data == null ||
          (data.totalIncome == 0 && data.totalExpense == 0)) {
        return const SizedBox.shrink();
      }

      final filter = controller.filterType.value;
      if (filter != ReportFilterType.all &&
          filter != ReportFilterType.liability &&
          filter != ReportFilterType.lend) {
        return const SizedBox.shrink();
      }

      final children = <Widget>[];

      if (data.totalExpense > 0) {
        children.add(
          TrendCard(
            title: el.tr(CcLocaleKeys.report_liability_out),
            amount: data.totalExpense,
            points: data.points,
            color: context.ccColorScheme.liabilitySecondary,
            range: controller.range.value,
            isIncome: false,
          ),
        );
      }

      if (data.totalIncome > 0) {
        if (children.isNotEmpty) {
          children.add(const CcSpaceLG());
        }
        children.add(
          TrendCard(
            title: el.tr(CcLocaleKeys.report_liability_in),
            amount: data.totalIncome,
            points: data.points,
            color: context.ccColorScheme.liability,
            range: controller.range.value,
            isIncome: true,
          ),
        );
      }

      if (children.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const CcSpaceLG(), ...children, const CcSpaceSM()],
      );
    });
  }
}
