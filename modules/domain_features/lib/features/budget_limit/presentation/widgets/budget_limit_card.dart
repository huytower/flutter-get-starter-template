import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';

/// Grid card for a budget item — mirrors the design of [_BudgetPreviewCard]
/// in wallet's budget_preview_section.
///
/// View mode: shows a ⠿ drag-indicator at the top-right; parent wraps this
/// in [LongPressDraggable] for hold-to-reorder.
///
/// Edit mode: shows iOS-style red (−) badge top-left and primary edit badge
/// top-right; drag handle is hidden.
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
      return '${(value / 1000000000).toStringAsFixed(1)}tỷ đ';
    }
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}tr đ';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k đ';
    return '$value đ';
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular progress ring + icon
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        value: stats.progress,
                        backgroundColor: accent.withOpacity(0.25),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                        strokeWidth: 3.5,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, size: 18, color: iconColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Budget name
              CcText(
                stats.budget.name,
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Percentage used
              CcText(
                el.tr(
                  CcLocaleKeys.budget_percent_used,
                  namedArgs: {'percent': '$pct'},
                ),
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              // Remaining / over — reuse existing locale keys
              CcText(
                stats.isOver
                    ? el.tr(
                        CcLocaleKeys.budget_over_by,
                        namedArgs: {
                          'amount': _fmtShort(stats.spent - stats.budget.limit),
                        },
                      )
                    : el.tr(
                        CcLocaleKeys.budget_remaining,
                        namedArgs: {'amount': _fmtShort(stats.remaining)},
                      ),
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // ── Drag indicator (view mode only) ─────────────────────────────────
        if (!isEditMode)
          Positioned(
            top: 6,
            right: 8,
            child: Icon(
              Icons.drag_indicator,
              color: scheme.onSurfaceVariant.withOpacity(0.4),
              size: 16,
            ),
          ),
        // ── Edit mode: delete badge (top-left) ───────────────────────────────
        if (isEditMode)
          Positioned(
            top: -1,
            left: -1,
            child: _EditBadge(
              icon: Icons.remove,
              color: Colors.red,
              onTap: onDelete,
            ),
          ),
        // ── Edit mode: edit badge (top-right) ────────────────────────────────
        if (isEditMode)
          Positioned(
            top: -1,
            right: -1,
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
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
        ),
        child: Icon(icon, color: Colors.white, size: 13),
      ),
    );
  }
}
