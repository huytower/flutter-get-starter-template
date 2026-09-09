import 'package:flutter/material.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import 'report_daily_group.dart';

class ReportDailyList extends StatelessWidget {
  const ReportDailyList({
    super.key,
    required this.transactions,
    required this.includeInvestmentAndLiability,
    required this.isEditMode,
  });

  final List<TransactionEntity> transactions;
  final bool includeInvestmentAndLiability;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((tx) => tx.amount != 0).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    final groups = <DateTime, List<TransactionEntity>>{};
    for (final tx in filtered) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groups.putIfAbsent(date, () => []).add(tx);
    }

    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final date in sortedDates)
          DailyGroup(
            date: date,
            transactions: groups[date]!,
            includeInvestmentAndLiability: includeInvestmentAndLiability,
            isEditMode: isEditMode,
          ),
      ],
    );
  }
}
