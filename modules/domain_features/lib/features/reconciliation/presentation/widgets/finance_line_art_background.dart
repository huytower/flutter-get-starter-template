import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';

/// Decorative page backdrop for the reconciliation screen: a soft mint
/// gradient with faint "finance" line art (trend lines with nodes, tiny bar
/// charts, coin rings) drawn along the edges.
///
/// Purely ornamental — it ignores pointers and is excluded from semantics.
class FinanceLineArtBackground extends StatelessWidget {
  const FinanceLineArtBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const BgGradientWidget(topAlpha: 45),
            CustomPaint(
              painter: _FinanceLineArtPainter(
                lineColor: scheme.primary.withValues(alpha: 0.28),
                nodeColor: scheme.primary.withValues(alpha: 0.45),
                fillColor: scheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceLineArtPainter extends CustomPainter {
  _FinanceLineArtPainter({
    required this.lineColor,
    required this.nodeColor,
    required this.fillColor,
  });

  final Color lineColor;
  final Color nodeColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final unit = w / 390; // scales the art with the screen width

    final line = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * unit
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final nodeStroke = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * unit;
    final nodeFill = Paint()..color = fillColor;
    final dot = Paint()..color = nodeColor;

    void node(Offset c, {bool solid = false}) {
      final r = 3.2 * unit;
      if (solid) {
        canvas.drawCircle(c, r, dot);
      } else {
        canvas.drawCircle(c, r, nodeFill);
        canvas.drawCircle(c, r, nodeStroke);
      }
    }

    void trend(List<Offset> points, {int solidIndex = -1}) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, line);
      for (var i = 0; i < points.length; i++) {
        node(points[i], solid: i == solidIndex);
      }
    }

    void bars(Offset base) {
      final heights = [6.0, 11.0, 8.0];
      for (var i = 0; i < heights.length; i++) {
        final x = base.dx + i * 4.5 * unit;
        canvas.drawLine(
          Offset(x, base.dy),
          Offset(x, base.dy - heights[i] * unit),
          line,
        );
      }
    }

    void coin(Offset c) {
      final r = 9 * unit;
      canvas.drawCircle(c, r, nodeFill);
      canvas.drawCircle(c, r, nodeStroke);
      canvas.drawCircle(c, r * 0.62, line);
      // A minimal "$": vertical stroke through an S-like pair of arcs.
      canvas.drawLine(
        Offset(c.dx, c.dy - r * 0.45),
        Offset(c.dx, c.dy + r * 0.45),
        line,
      );
    }

    // Top-right: connector into a coin, with a small bar chart.
    trend([
      Offset(w * 0.84, h * 0.115),
      Offset(w * 0.93, h * 0.115),
      Offset(w * 0.985, h * 0.10),
    ], solidIndex: 0);
    coin(Offset(w * 0.975, h * 0.085));
    bars(Offset(w * 0.955, h * 0.185));

    // Left edge, upper: short rising trend.
    trend([
      Offset(w * 0.005, h * 0.19),
      Offset(w * 0.035, h * 0.205),
      Offset(w * 0.075, h * 0.175),
    ]);

    // Between the first cards: stepped line dropping from the left.
    trend([
      Offset(w * 0.03, h * 0.335),
      Offset(w * 0.10, h * 0.365),
      Offset(w * 0.19, h * 0.36),
      Offset(w * 0.30, h * 0.345),
    ], solidIndex: 2);
    bars(Offset(w * 0.335, h * 0.372));

    // Mid-left: line threading down past the second card.
    trend([
      Offset(w * 0.18, h * 0.405),
      Offset(w * 0.18, h * 0.435),
      Offset(w * 0.065, h * 0.455),
    ], solidIndex: 0);
    bars(Offset(w * 0.20, h * 0.398));

    // Lower-left and lower-middle accents.
    trend([
      Offset(w * 0.01, h * 0.70),
      Offset(w * 0.075, h * 0.672),
      Offset(w * 0.155, h * 0.70),
      Offset(w * 0.30, h * 0.69),
    ], solidIndex: 3);
    bars(Offset(w * 0.40, h * 0.708));

    trend([
      Offset(w * 0.25, h * 0.875),
      Offset(w * 0.31, h * 0.865),
      Offset(w * 0.40, h * 0.845),
    ], solidIndex: 1);
    bars(Offset(w * 0.415, h * 0.878));

    // Bottom-right: coin with a connector, mirroring the top one.
    trend([Offset(w * 0.90, h * 0.905), Offset(w * 0.95, h * 0.918)]);
    coin(Offset(w * 0.975, h * 0.93));

    // Bottom-left: small molecule-like cluster.
    final cluster = Offset(w * 0.04, h * 0.955);
    canvas.drawLine(cluster, cluster + Offset(14 * unit, -8 * unit), line);
    canvas.drawLine(cluster, cluster + Offset(12 * unit, 9 * unit), line);
    canvas.drawLine(cluster, cluster + Offset(-10 * unit, 6 * unit), line);
    node(cluster);
    node(cluster + Offset(14 * unit, -8 * unit));
    node(cluster + Offset(12 * unit, 9 * unit));
  }

  @override
  bool shouldRepaint(_FinanceLineArtPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.nodeColor != nodeColor ||
      oldDelegate.fillColor != fillColor;
}
