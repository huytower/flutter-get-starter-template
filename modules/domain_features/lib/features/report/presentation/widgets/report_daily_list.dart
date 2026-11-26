import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import 'report_daily_group.dart';

class ReportDailyList extends StatelessWidget {
  const ReportDailyList({
    super.key,
    required this.transactions,
    required this.includeInvestmentAndLiability,
    required this.hasEditMode,
    this.reconciledUntil,
  });

  final List<TransactionEntity> transactions;
  final bool includeInvestmentAndLiability;
  final bool hasEditMode;

  /// Latest reconciliation: edit/delete is offered only for transactions
  /// dated after it (unreconciled). Null when nothing was reconciled yet.
  final DateTime? reconciledUntil;

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((tx) {
      return tx.amount != 0;
    }).toList();
    if (filtered.isEmpty) {
      return CcSectionEmptyState(
        message: el.tr(PrjLocaleKeys.report_no_expense),
      );
    }

    final groups = <DateTime, List<TransactionEntity>>{};
    for (final tx in filtered) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groups.putIfAbsent(date, () => []).add(tx);
    }

    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    final dayGroups = [
      for (final date in sortedDates)
        ReportDailyGroup(
          key: ValueKey(date.toIso8601String()),
          date: date,
          transactions: groups[date]!,
          includeInvestmentAndLiability: includeInvestmentAndLiability,
          hasEditMode: hasEditMode,
          reconciledUntil: reconciledUntil,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CcSpaceMD(),
        // Landscape tablet: days flow across three columns (newest first,
        // left to right) instead of one stretched list.
        if (CcTwoColumn.shouldUse(context))
          CcMaxWidth(
            maxWidth: CcTwoColumn.defaultMaxWidth,
            child: CcMultiColumn(children: dayGroups),
          )
        else
          ...dayGroups,
      ],
    );
  }
}
