import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/money_format.dart';
import '../../domain/entities/trend_data_entity.dart';
import '../../domain/report_range.dart';

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.data,
    required this.range,
    required this.onNext,
    required this.onPrevious,
    required this.canNext,
    required this.canPrevious,
  });

  final TrendDataEntity data;
  final ReportRange range;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool canNext;
  final bool canPrevious;

  @override
  Widget build(BuildContext context) {
    final points = data.points;
    if (points.isEmpty) return const SizedBox.shrink();

    final incomeColor = context.ccColorScheme.primary;
    final expenseColor = context.ccColorScheme.error;

    final maxVal = points.fold<double>(0, (max, p) {
      final localMax = p.income > p.expense ? p.income : p.expense;
      return localMax > max ? localMax : max;
    });
    final maxY = maxVal <= 0 ? 100.0 : maxVal * 1.3;

    final isCurved = range != ReportRange.yearly;

    return Column(
      children: [
        _buildHeader(context, incomeColor, expenseColor),
        SizedBox(height: context.respDim(24)),
        SizedBox(
          height: context.respDim(220),
          child: LineChart(
            LineChartData(
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        formatVndShort(spot.y),
                        TextStyle(
                          color: spot.barIndex == 0
                              ? incomeColor
                              : expenseColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length)
                        return const SizedBox.shrink();

                      // For Yearly, only show quarterly labels as per requirement
                      if (range == ReportRange.yearly && index % 3 != 0) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: EdgeInsets.only(top: context.respDim(8.0)),
                        child: CcText(
                          points[index].label,
                          textStyle: context.ccTextTheme.labelSmall?.copyWith(
                            fontSize: context.respFontSize(
                              CcTypographyParams.labelSmall,
                            ),
                            color: context.ccColorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                    reservedSize: context.respDim(32),
                  ),
                ),
              ),
              lineBarsData: [
                _buildLine(
                  context,
                  points,
                  (p) => p.income,
                  incomeColor,
                  isCurved,
                ),
                _buildLine(
                  context,
                  points,
                  (p) => p.expense,
                  expenseColor,
                  isCurved,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartBarData _buildLine(
    BuildContext context,
    List<TrendPoint> points,
    double Function(TrendPoint) valSelector,
    Color color,
    bool isCurved,
  ) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < points.length; i++)
          FlSpot(i.toDouble(), valSelector(points[i])),
      ],
      isCurved: isCurved,
      color: color,
      barWidth: context.respDim(3),
      isStrokeCapRound: true,
      dotData: FlDotData(show: !isCurved || range == ReportRange.monthly),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color incomeColor,
    Color expenseColor,
  ) {
    String subtitle = "";
    if (range == ReportRange.weekly) {
      subtitle = el.tr(CcLocaleKeys.report_this_week);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CcText(
              el.tr(CcLocaleKeys.report_income_expense),
              textStyle: context.ccTextTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle.isNotEmpty)
              CcText(
                subtitle,
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: context.ccColorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        Row(
          children: [
            if (range != ReportRange.weekly) ...[
              IconButton(
                onPressed: canPrevious ? onPrevious : null,
                icon: Icon(
                  Icons.chevron_left,
                  color: canPrevious ? null : context.ccColorScheme.outline,
                ),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: canNext ? onNext : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: canNext ? null : context.ccColorScheme.outline,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
            SizedBox(width: context.respDim(8)),
            _legendDot(context, incomeColor, el.tr(CcLocaleKeys.common_income)),
            SizedBox(width: context.respDim(12)),
            _legendDot(
              context,
              expenseColor,
              el.tr(CcLocaleKeys.common_expense),
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: context.respDim(8),
          height: context.respDim(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: context.respDim(4)),
        CcText(label, textStyle: context.ccTextTheme.labelSmall),
      ],
    );
  }
}
