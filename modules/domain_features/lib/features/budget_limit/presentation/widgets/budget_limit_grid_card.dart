import 'package:cc_sdk/core/extensions/common/cc_int_extension.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';
import 'budget_limit_pie_chart.dart';

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
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(context.respDim(20)),
            // Subtle border to define shape in light mode where surface color
            // might blend into the background.
            border: Border.all(
              color: scheme.onSurface.withOpacity(0.08),
              width: context.respDim(1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                            stats.budget.name,
                            maxLines: 1,
                            textStyle: context.ccTextTheme.labelLarge?.copyWith(
                              fontWeight: CcTypographyParams.bold,
                              color: scheme.onSurface,
                              fontSize: context.respFontSize(14),
                            ),
                          ),
                        ),
                        CcText(
                          stats.budget.limit.formatShort(),
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
              Divider(
                color: scheme.onSurface.withOpacity(0.06),
                height: context.respDim(1),
              ),
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
                  BudgetLimitPieChart(
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
            top: context.respDim(8),
            right: context.respDim(8),
            child: Icon(
              Icons.drag_indicator,
              color: scheme.onSurfaceVariant.withOpacity(0.2),
              size: context.respIconSize(baseSize: 12),
            ),
          ),
        // ── Edit mode: delete badge (top-left) ───────────────────────────────
        if (isEditMode)
          Positioned(
            top: context.respDim(-4),
            left: context.respDim(-4),
            child: _EditBadge(
              icon: Icons.remove,
              color: scheme.error,
              onTap: onDelete,
            ),
          ),
        // ── Edit mode: edit badge (top-right) ────────────────────────────────
        if (isEditMode)
          Positioned(
            top: context.respDim(-4),
            right: context.respDim(-4),
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
    final scheme = context.ccColorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.respDim(24),
        height: context.respDim(24),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surface, width: context.respDim(2)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.2),
              blurRadius: context.respDim(4),
              offset: Offset(0, context.respDim(2)),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: scheme.onPrimary,
          size: context.respIconSize(baseSize: 14),
        ),
      ),
    );
  }
}
