import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/money_format.dart';
import '../../domain/entities/trend_data_entity.dart';
import '../../domain/report_range.dart';

class TrendCard extends StatelessWidget {
  const TrendCard({
    super.key,
    required this.title,
    required this.amount,
    required this.points,
    required this.color,
    required this.range,
    this.isIncome = false,
  });

  final String title;
  final double amount;
  final List<TrendPoint> points;
  final Color color;
  final ReportRange range;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final isCurved = range != ReportRange.yearly;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isIncome ? Icons.north_east : Icons.south_west,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              CcText(
                title,
                textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.ccColorScheme.onSurface,
                ),
              ),
              const Spacer(),
              CcText(
                formatVndShort(amount),
                textStyle: context.ccTextTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.ccColorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: points.length.toDouble() - 1,
                minY: points.isEmpty ? 0 : points.map((p) => isIncome ? p.income : p.expense).reduce((a, b) => a < b ? a : b) * 0.95,
                maxY: points.isEmpty ? 100 : points.map((p) => isIncome ? p.income : p.expense).reduce((a, b) => a > b ? a : b) * 1.05,
                lineTouchData: const LineTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < points.length; i++)
                        FlSpot(i.toDouble(), isIncome ? points[i].income : points[i].expense),
                    ],
                    isCurved: isCurved,
                    curveSmoothness: 0.3,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: range != ReportRange.weekly,
                      getDotPainter: (spot, percent, barData, index) {
                        bool shouldShow = false;
                        if (range == ReportRange.monthly) shouldShow = true;
                        if (range == ReportRange.yearly && index % 3 == 0) shouldShow = true;
                        
                        return FlDotCirclePainter(
                          radius: shouldShow ? 2.5 : 0,
                          color: color,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.03),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (range != ReportRange.weekly) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < points.length; i++)
                  if (range == ReportRange.monthly || (range == ReportRange.yearly && i % 3 == 0))
                    CcText(
                      points[i].label,
                      textStyle: context.ccTextTheme.labelSmall?.copyWith(
                        color: context.ccColorScheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
