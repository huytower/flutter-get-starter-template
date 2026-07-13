import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/util/icon_utils.dart';
import '../../../../core/util/money_format.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';

class ReportDailyList extends StatelessWidget {
  const ReportDailyList({super.key, required this.transactions});

  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    // Group transactions by date
    final groups = <DateTime, List<TransactionEntity>>{};
    for (final tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groups.putIfAbsent(date, () => []).add(tx);
    }

    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final date in sortedDates)
          _DailyGroup(date: date, transactions: groups[date]!),
      ],
    );
  }
}

class _DailyGroup extends StatelessWidget {
  const _DailyGroup({required this.date, required this.transactions});

  final DateTime date;
  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    final totalDaily = transactions.fold<double>(0, (sum, tx) {
      if (tx.type == TransactionType.income) return sum + tx.amount;
      if (tx.type == TransactionType.expense) return sum - tx.amount;
      return sum;
    });

    final isPositive = totalDaily > 0;
    final isNegative = totalDaily < 0;
    final amountPrefix = isPositive ? '+' : (isNegative ? '-' : '');
    final amountText = "$amountPrefix${formatVnd(totalDaily.abs().toInt())} đ";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CcText(
                  el.DateFormat('dd').format(date),
                  textStyle: context.ccTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final weekdayNames = el
                            .tr(CcLocaleKeys.common_weekday_names)
                            .split('|');
                        final weekdayIndex = date.weekday - 1;
                        final weekdayText =
                            (weekdayIndex >= 0 &&
                                weekdayIndex < weekdayNames.length)
                            ? weekdayNames[weekdayIndex]
                            : el.DateFormat(
                                'EEEE',
                                context.locale.languageCode,
                              ).format(date);

                        return CcText(
                          weekdayText,
                          textStyle: context.ccTextTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    CcText(
                      el.DateFormat(
                        'MMMM, yyyy',
                        context.locale.languageCode,
                      ).format(date),
                      textStyle: context.ccTextTheme.labelSmall?.copyWith(
                        color: context.ccColorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CcText(
                  amountText,
                  textStyle: context.ccTextTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? PrjColors.success : PrjColors.error,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: context.ccColorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          for (final tx in transactions) _TransactionTile(transaction: tx),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountText =
        "${isIncome ? '+' : '-'}${formatVnd(transaction.amount)} đ";

    Widget getIcon() {
      if (transaction.categoryIconCode != null) {
        return Icon(
          iconDataFromCode(
            transaction.categoryIconCode!,
            fontFamily: transaction.categoryIconFamily,
          ),
          size: 20,
          color: isIncome
              ? context.ccColorScheme.primary
              : context.ccColorScheme.error,
        );
      }
      return Icon(
        isIncome ? Icons.north_east : Icons.south_west,
        size: 20,
        color: isIncome
            ? context.ccColorScheme.primary
            : context.ccColorScheme.error,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome
                  ? context.ccColorScheme.primary.withValues(alpha: 0.1)
                  : context.ccColorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: getIcon()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  transaction.category,
                  textStyle: context.ccTextTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                CcText(
                  transaction.note ?? transaction.category,
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    color: context.ccColorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CcText(
                amountText,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? PrjColors.success : PrjColors.error,
                ),
              ),
              CcText(
                el.DateFormat('dd/MM').format(transaction.date),
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                  fontSize: context.respFontSize(CcTypographyParams.labelSmall),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
