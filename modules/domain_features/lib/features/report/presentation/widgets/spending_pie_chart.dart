import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../domain/entities/category_spending_entity.dart';
import 'category_legend_tile.dart';

class SpendingPieChart extends StatefulWidget {
  const SpendingPieChart({
    super.key,
    required this.slices,
    required this.total,
  });

  final List<CategorySpendingEntity> slices;
  final int total;

  @override
  State<SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<SpendingPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: context.respDim(200),
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: context.respDim(4),
              centerSpaceRadius: context.respDim(40),
              sections: _buildSections(context),
            ),
          ),
        ),
        SizedBox(height: context.respDim(24)),
        Column(
          children: [
            for (var i = 0; i < widget.slices.length; i++)
              CategoryLegendTile(
                slice: widget.slices[i],
                color: widget.slices[i].color ?? reportPalette(context)[i % reportPalette(context).length],
              ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(BuildContext context) {
    final palette = reportPalette(context);
    return List.generate(widget.slices.length, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? context.respDim(60.0) : context.respDim(50.0);
      final slice = widget.slices[i];
      final color = slice.color ?? palette[i % palette.length];

      return PieChartSectionData(
        color: color,
        value: slice.amount.toDouble(),
        title: isTouched ? '${slice.percent}%' : '',
        radius: radius,
        titleStyle: context.ccTextTheme.labelSmall?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }
}

List<Color> reportPalette(BuildContext context) {
  return [
    PrjColors.primary,
    PrjColors.secondary,
    PrjColors.pink,
    PrjColors.warning,
    PrjColors.success,
    PrjColors.error,
    PrjColors.secondaryContainer,
  ];
}
