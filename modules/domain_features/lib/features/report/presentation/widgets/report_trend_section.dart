import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../domain/entities/trend_data_entity.dart';
import '../get_x/report_controller.dart';
import 'trend_card.dart';

class ReportTrendSection extends StatelessWidget {
  const ReportTrendSection({
    super.key,
    required this.controller,
    required this.data,
  });

  final ReportController controller;
  final TrendDataEntity data;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (data.points.isEmpty) return const SizedBox.shrink();

      final filter = controller.filterType.value;
      if (filter != ReportFilterType.all &&
          filter != ReportFilterType.expense &&
          filter != ReportFilterType.income) {
        return const SizedBox.shrink();
      }

      final children = <Widget>[];
      if (filter == ReportFilterType.all ||
          filter == ReportFilterType.expense) {
        children.add(
          TrendCard(
            title: el.tr(CcLocaleKeys.common_expense),
            amount: data.totalExpense,
            points: data.points,
            color: context.ccColorScheme.error,
            range: controller.range.value,
            isIncome: false,
          ),
        );
      }

      if (filter == ReportFilterType.all && children.isNotEmpty) {
        children.add(const CcSpaceLG());
      }

      if (filter == ReportFilterType.all || filter == ReportFilterType.income) {
        children.add(
          TrendCard(
            title: el.tr(CcLocaleKeys.common_income),
            amount: data.totalIncome,
            points: data.points,
            color: PrjColors.success,
            range: controller.range.value,
            isIncome: true,
          ),
        );
      }

      return Column(children: children);
    });
  }
}
