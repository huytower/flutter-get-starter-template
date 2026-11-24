import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../domain/entities/trend_data_entity.dart';
import '../get_x/report_controller.dart';
import 'report_card_pair.dart';
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
      final filter = controller.filterType.value;
      if (data.points.isEmpty) return const SizedBox.shrink();

      if (filter != ReportFilterType.all &&
          filter != ReportFilterType.expense &&
          filter != ReportFilterType.income) {
        return const SizedBox.shrink();
      }

      final cards = <Widget>[];
      if (filter == ReportFilterType.all ||
          filter == ReportFilterType.expense) {
        cards.add(
          TrendCard(
            title: el.tr(PrjLocaleKeys.common_expense),
            amount: data.totalExpense,
            points: data.points,
            color: context.expenseAccent,
            range: controller.range.value,
            hasIncome: false,
          ),
        );
      }

      if (filter == ReportFilterType.all || filter == ReportFilterType.income) {
        cards.add(
          TrendCard(
            title: el.tr(PrjLocaleKeys.common_income),
            amount: data.totalIncome,
            points: data.points,
            color: context.incomeAccent,
            range: controller.range.value,
            hasIncome: true,
          ),
        );
      }

      return ReportCardPair(cards: cards);
    });
  }
}
