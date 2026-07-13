import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/util/money_format.dart';
import '../../domain/entities/monthly_summary_entity.dart';

/// Grouped bar chart comparing income vs expense per month
/// ("Biểu đồ cột: so sánh thu nhập và chi tiêu theo từng tháng").
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key, required this.months});

  final List<MonthlySummaryEntity> months;

  static const Color _incomeColor = PrjColors.success;
  static const Color _expenseColor = PrjColors.error;

  @override
  Widget build(BuildContext context) {
    final maxValue = months.fold<double>(0, (max, m) {
      final localMax = (m.income > m.expense ? m.income : m.expense).toDouble();
      return localMax > max ? localMax : max;
    });
    // Headroom above the tallest bar; guard the all-zero case.
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _legendDot(
              context,
              _incomeColor,
              el.tr(CcLocaleKeys.report_income_short),
            ),
            const SizedBox(width: 16),
            _legendDot(
              context,
              _expenseColor,
              el.tr(CcLocaleKeys.report_expense_short),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      formatVndShort(rod.toY),
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: context.respFontSize(
                          CcTypographyParams.labelMedium,
                        ),
                      ),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: maxY / 4,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: CcText(
                          formatVndShort(value),
                          textStyle: context.ccTextTheme.labelSmall?.copyWith(
                            color: context.ccColorScheme.onSurfaceVariant,
                            fontSize: context.respFontSize(
                              CcTypographyParams.labelSmall,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= months.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: CcText(
                          months[index].shortLabel,
                          textStyle: context.ccTextTheme.labelSmall?.copyWith(
                            color: context.ccColorScheme.onSurfaceVariant,
                            fontSize: context.respFontSize(
                              CcTypographyParams.labelSmall,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < months.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      _rod(months[i].income, _incomeColor),
                      _rod(months[i].expense, _expenseColor),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartRodData _rod(num value, Color color) {
    return BarChartRodData(
      toY: value.toDouble(),
      color: color,
      width: 9,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        CcText(label, textStyle: context.ccTextTheme.bodySmall),
      ],
    );
  }
}
