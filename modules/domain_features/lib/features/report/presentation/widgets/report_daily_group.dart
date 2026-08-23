import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/money_format_helper.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import 'report_daily_list_helpers.dart';
import 'report_transaction_tile.dart';

class DailyGroup extends StatelessWidget {
  const DailyGroup({
    required this.date,
    required this.transactions,
    required this.includeInvestmentAndLiability,
    required this.isEditMode,
  });

  final DateTime date;
  final List<TransactionEntity> transactions;
  final bool includeInvestmentAndLiability;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final totalDaily = computeDailyTotal(
      transactions,
      includeInvestmentAndLiability: includeInvestmentAndLiability,
    );

    final isPositive = totalDaily > 0;
    final isNegative = totalDaily < 0;
    final amountPrefix = isPositive ? '+' : (isNegative ? '-' : '');
    final amountText = "$amountPrefix${formatVnd(totalDaily.abs().toInt())} đ";

    return Container(
      margin: EdgeInsets.only(bottom: context.respDim(16)),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surfaceContainer,
        borderRadius: context.brLg,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(
              context.respPadding(CcPaddingParams.SPACE_MD),
            ),
            child: Row(
              children: [
                CcText(
                  el.DateFormat('dd').format(date),
                  textStyle: context.ccTextTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const CcSpaceMD(),
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
            height: context.respDim(1),
            color: context.ccColorScheme.outlineVariant.withValues(alpha: 0.1),
          ),
          for (final tx in transactions) TransactionTile(
            transaction: tx,
            isEditMode: isEditMode,
          ),
        ],
      ),
    );
  }
}
