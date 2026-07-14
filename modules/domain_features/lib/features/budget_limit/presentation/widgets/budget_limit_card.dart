import 'dart:math';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';

/// Grid card for a budget item — updated to match the new dark sleek design.
///
/// View mode: shows a ⠿ drag-indicator at the top-right; parent wraps this
/// in [LongPressDraggable] for hold-to-reorder.
///
/// Edit mode: shows red (−) delete and primary edit badges; drag handle is hidden.
class BudgetLimitGridCard extends StatelessWidget {
  final BudgetLimitStatsEntity stats;
  final bool isEditMode;
  final bool isDragging;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetLimitGridCard({
    super.key,
    required this.stats,
    this.isEditMode = false,
    this.isDragging = false,
    this.onEdit,
    this.onDelete,
  });

  static String _fmtShort(int value) {
    if (value >= 1000000000) {
      final val = value / 1000000000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)} tỷ';
    }
    if (value >= 1000000) {
      final val = value / 1000000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}tr';
    }
    if (value >= 1000) {
      final val = value / 1000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(0)}k';
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final iconColor = stats.color ?? scheme.primary;
    final accent = stats.isOver ? scheme.error : iconColor;
    final pct = (stats.progress * 100).round();

    final iconData = stats.iconCode > 0
        ? iconDataFromCode(stats.iconCode, fontFamily: stats.iconFamily)
        : Icons.savings;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Main card ───────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.all(context.respDim(12)),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(context.respDim(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Icon + Name/Limit
              Row(
                children: [
                  Container(
                    width: context.respDim(42),
                    height: context.respDim(42),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(context.respDim(12)),
                    ),
                    child: Icon(
                      iconData,
                      size: context.respIconSize(baseSize: 20),
                      color: iconColor,
                    ),
                  ),
                  SizedBox(width: context.respDim(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: CcText(
                            stats.budget.name.toLowerCase(),
                            maxLines: 1,
                            textStyle: context.ccTextTheme.labelLarge?.copyWith(
                              fontWeight: CcTypographyParams.bold,
                              color: scheme.onSurface,
                              fontSize: context.respFontSize(14),
                            ),
                          ),
                        ),
                        CcText(
                          '${_fmtShort(stats.budget.limit)}',
                          textStyle: context.ccTextTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant.withOpacity(0.6),
                            fontSize: context.respFontSize(11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const CcSpaceXS(),
              // Subtle Divider
              Divider(color: scheme.onSurface.withOpacity(0.06), height: 1),
              const CcSpaceXS(),
              // Bottom Row: Usage Percent + Mini Pie Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CcText(
                    el.tr(
                      CcLocaleKeys.budget_percent_used,
                      namedArgs: {'percent': '$pct'},
                    ),
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withOpacity(0.6),
                      fontSize: context.respFontSize(12),
                    ),
                  ),
                  _PieChart(
                    progress: stats.progress,
                    color: accent,
                    size: context.respDim(24),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ── Drag indicator (view mode only) ─────────────────────────────────
        if (!isEditMode)
          Positioned(
            top: 10,
            right: 10,
            child: Icon(
              Icons.drag_indicator,
              color: scheme.onSurfaceVariant.withOpacity(0.2),
              size: 14,
            ),
          ),
        // ── Edit mode: delete badge (top-left) ───────────────────────────────
        if (isEditMode)
          Positioned(
            top: -4,
            left: -4,
            child: _EditBadge(
              icon: Icons.remove,
              color: context.ccColorScheme.error,
              onTap: onDelete,
            ),
          ),
        // ── Edit mode: edit badge (top-right) ────────────────────────────────
        if (isEditMode)
          Positioned(
            top: -4,
            right: -4,
            child: _EditBadge(
              icon: Icons.edit,
              color: scheme.primary,
              onTap: onEdit,
            ),
          ),
      ],
    );
  }
}

class _EditBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _EditBadge({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.respDim(24),
        height: context.respDim(24),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: context.ccColorScheme.surface, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: context.respIconSize(baseSize: 14),
        ),
      ),
    );
  }
}

/// A simple pie chart widget for showing budget progress.
class _PieChart extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;

  const _PieChart({
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
