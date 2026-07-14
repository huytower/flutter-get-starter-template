import 'dart:math';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// A simple pie chart widget for showing budget progress.
class BudgetLimitPieChart extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;

  const BudgetLimitPieChart({
    super.key,
    required this.progress,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PieChartPainter(
        progress: progress.clamp(0.0, 1.0),
        color: color,
        backgroundColor: context.ccColorScheme.onSurface.withOpacity(0.1),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _PieChartPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background circle (the "outline")
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw the progress segment (the "pie slice")
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Start from top (-90 degrees)
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, true, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.backgroundColor != backgroundColor;
}
