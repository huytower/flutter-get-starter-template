import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/money_format.dart';
import '../../domain/entities/category_spending_entity.dart';
import 'category_legend_tile.dart';
import 'report_palette.dart';

/// Donut chart of spending share by category with the range total in the hole,
/// followed by a colour-matched legend ("Biểu đồ tròn: tỷ trọng chi tiêu").
class SpendingPieChart extends StatelessWidget {
  const SpendingPieChart({
    super.key,
    required this.slices,
    required this.total,
  });

  final List<CategorySpendingEntity> slices;
  final int total;

  /// Slices below this share are drawn without an inline label to avoid clutter.
  static const double _minLabelFraction = 0.06;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 56,
                  sections: [
                    for (var i = 0; i < slices.length; i++)
                      _section(context, slices[i], i),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CcText(
                    'Tổng chi',
                    textStyle: context.ccTextTheme.bodySmall?.copyWith(
                      color: context.ccColorScheme.onSurfaceVariant,
                    ),
                  ),
                  CcText(
                    formatVndShort(total),
                    textStyle: context.ccTextTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < slices.length; i++)
          CategoryLegendTile(
            slice: slices[i],
            color: reportSliceColor(slices[i], i),
          ),
      ],
    );
  }

  PieChartSectionData _section(
    BuildContext context,
    CategorySpendingEntity slice,
    int index,
  ) {
    final showLabel = slice.fraction >= _minLabelFraction;
    return PieChartSectionData(
      value: slice.amount.toDouble(),
      color: reportSliceColor(slice, index),
      radius: 44,
      title: showLabel ? '${slice.percent}%' : '',
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
