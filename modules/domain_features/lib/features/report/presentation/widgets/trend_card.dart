import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/util/money_format_helper.dart';
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

    return SizedBox(
      height: context.respDim(180),
      child: _buildCard(context, isCurved),
    );
  }

  Widget _buildCard(BuildContext context, bool isCurved) {
    return Container(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(context.respDim(20)),
        border: Border.all(
          color: context.ccColorScheme.outlineVariant.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context),
          const CcSpaceXL(),
          Expanded(child: _buildChart(context, isCurved)),
          const CcSpaceMD(),
          _buildLabels(context),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(context.respDim(10)),
          ),
          child: Icon(
            isIncome ? Icons.north_east : Icons.south_west,
            color: color,
            size: context.respIconSize(baseSize: 18),
          ),
        ),
        const CcSpaceMD(),
        CcText(
          title,
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            fontWeight: CcTypographyParams.semiBold,
            color: context.ccColorScheme.onSurface
          ),
        ),
        const Spacer(),
        CcText(
          formatVndShort(amount),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.onSurface
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, bool isCurved) {
    return SizedBox(
      height: context.respDim(50),
      child: LineChart(_buildChartData(context, isCurved)),
    );
  }

  LineChartData _buildChartData(BuildContext context, bool isCurved) {
    final values = points.map((p) => isIncome ? p.income : p.expense).toList();

    return LineChartData(
      minX: 0,
      maxX: points.length.toDouble() - 1,
      minY: values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b) * 0.95,
      maxY: values.isEmpty
          ? 100
          : values.reduce((a, b) => a > b ? a : b) * 1.05,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < points.length; i++)
              FlSpot(
                i.toDouble(),
                isIncome ? points[i].income : points[i].expense,
              ),
          ],
          isCurved: isCurved,
          curveSmoothness: 0.3,
          color: color,
          barWidth: context.respDim(2),
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              bool shouldShow = false;
              if (range == ReportRange.weekly) shouldShow = true;
              if (range == ReportRange.monthly) shouldShow = true;
              if (range == ReportRange.yearly && index % 3 == 0)
                shouldShow = true;

              return FlDotCirclePainter(
                radius: shouldShow ? context.respDim(2.5) : 0,
                color: color,
                strokeWidth: 0,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildLabels(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < points.length; i++)
          if (range == ReportRange.weekly ||
              range == ReportRange.monthly ||
              (range == ReportRange.yearly && i % 3 == 0))
            CcText(
              range == ReportRange.weekly
                  ? DateFormat('dd/MM').format(points[i].date)
                  : points[i].label,
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant
              ),
            ),
      ],
    );
  }
}
