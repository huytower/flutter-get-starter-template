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
        const Positioned.fill(child: CcGlassyGradient()),
        // ── Main card ───────────────────────────────────────────────────────
        _buildMainCard(context, iconColor, iconData, pct, accent),

        // ── Drag indicator (view mode only) ─────────────────────────────────
        if (!isEditMode) _buildDragIndicator(context),

        // ── Edit mode badges ───────────────────────────────────────────────
        if (isEditMode) ..._buildEditBadges(context),
      ],
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    Color iconColor,
    IconData iconData,
    int pct,
    Color accent,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      padding: EdgeInsets.all(context.respDim(12)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _cardBackgroundColor(context, stats.color),
        borderRadius: BorderRadius.circular(context.respDim(20)),
        border: Border.all(
          color: scheme.onSurface.withOpacity(0.08),
          width: context.respDim(1),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.12),
            blurRadius: context.respDim(20),
            offset: Offset(0, context.respDim(10)),
            spreadRadius: context.respDim(-5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(context, iconColor, iconData),
          const CcSpaceXS(),
          Divider(
            color: scheme.onSurface.withOpacity(0.06),
            height: context.respDim(1),
          ),
          const CcSpaceXS(),
          _buildFooter(context, pct, accent),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color iconColor,
    IconData iconData,
  ) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Container(
          width: context.respDim(35),
          height: context.respDim(35),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(context.respDim(20)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(
                child: CcGlassyGradient(endColor: Color(0xFFE0E0E0)),
              ),
              Icon(
                iconData,
                size: context.respIconSize(baseSize: 20),
                color: iconColor,
              ),
            ],
          ),
        ),
        const CcSpaceXS(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CcText(
                stats.budget.name,
                maxLines: 2,
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onSurface,
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
    );
  }

  Widget _buildFooter(BuildContext context, int pct, Color accent) {
    final scheme = context.ccColorScheme;

    return Row(
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
          size: context.respDim(20),
        ),
      ],
    );
  }

  Widget _buildDragIndicator(BuildContext context) {
    return Positioned(
      top: context.respDim(8),
      right: context.respDim(8),
      child: Icon(
        Icons.drag_indicator,
        color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.2),
        size: context.respIconSize(baseSize: 12),
      ),
    );
  }

  List<Widget> _buildEditBadges(BuildContext context) {
    final scheme = context.ccColorScheme;
    return [
      Positioned(
        top: context.respDim(-4),
        left: context.respDim(-4),
        child: _EditBadge(
          icon: Icons.remove,
          color: scheme.error,
          onTap: onDelete,
        ),
      ),
      Positioned(
        top: context.respDim(-4),
        right: context.respDim(-4),
        child: _EditBadge(
          icon: Icons.edit,
          color: scheme.primary,
          onTap: onEdit,
        ),
      ),
    ];
  }

  Color _cardBackgroundColor(BuildContext context, Color? categoryColor) {
    return context.ccColorScheme.primaryContainer.withValues(alpha: 0.1);
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
