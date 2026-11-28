import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/budget/budget_name_helper.dart';
import '../../../../core/presentation/helper/transaction_form_helpers.dart';
import '../../../../core/presentation/widgets/prj_flip_card.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';
import 'budget_limit_grid_card_detail.dart';

/// Grid card for a budget item — uses an up-down 3D flashcard flip via
/// [PrjFlipCard] to reveal [BudgetLimitGridCardDetail].
///
/// View mode: tapping flips between front summary and back detail layout; holding 300ms allows drag-to-reorder.
/// Edit mode: shows red (−) delete and primary edit badges; drag handle and flip are disabled.
class BudgetLimitGridCard extends StatelessWidget {
  final BudgetLimitStatsEntity stats;
  final bool hasEditMode;
  final bool hasDragging;
  final bool showDragHandle;
  final bool hasFlippable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetLimitGridCard({
    super.key,
    required this.stats,
    this.hasEditMode = false,
    this.hasDragging = false,
    this.showDragHandle = true,
    this.hasFlippable = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasFlippable) {
      return _buildFrontCard(context);
    }

    return PrjFlipCard(
      enabled: !hasEditMode,
      front: _buildFrontCard(context),
      back: BudgetLimitGridCardDetail(
        stats: stats,
        hasEditMode: hasEditMode,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    final scheme = context.ccColorScheme;
    final iconColor = stats.color ?? scheme.primary;
    final accent = switch (stats.status) {
      BudgetLimitStatus.over => scheme.error,
      BudgetLimitStatus.nearLimit => PrjColors.warning,
      BudgetLimitStatus.safe => iconColor,
    };
    final pct = (stats.percentUsed * 100).round();

    final iconData = stats.iconCode > 0
        ? iconDataFromCode(stats.iconCode, fontFamily: stats.iconFamily)
        : Icons.savings;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: CcGlassyGradientBackground()),
        // ── Main card ───────────────────────────────────────────────────────
        _buildMainCard(context, iconColor, iconData, pct, accent),

        // ── Indicator icons ────────────────────────────────────────────────
        _buildIndicatorIcons(
          context,
          hasEditMode: hasEditMode,
          showDragHandle: showDragHandle,
        ),

        // ── Edit mode badges ───────────────────────────────────────────────
        if (hasEditMode) ..._buildEditBadges(context),
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
        borderRadius: context.brLg,
        border: context.borderSubtle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(context, iconColor, iconData),
          CcDividerLine(color: scheme.onSurface.withOpacity(0.06)),
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
            borderRadius: context.brLg,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CcGlassyGradientIcon(
                  centerColor: iconColor.withAlpha(10),
                  endColor: iconColor.withAlpha(20),
                ),
              ),
              Icon(
                iconData,
                size: context.respIconSize(baseSize: 20),
                color: iconColor,
              ),
            ],
          ),
        ),
        const CcSpaceSM(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: context.respDim(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  _getDisplayName(context),
                  maxLines: 2,
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    fontWeight: CcTypographyParams.bold,
                    color: scheme.onSurface,
                  ),
                ),
                CcText(
                  TransactionFormHelpers.formatShortWithSymbol(
                    stats.budget.limit,
                    currencyCode: stats.budget.currencyCode,
                  ),
                  textStyle: context.ccTextTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayName(BuildContext context) {
    return BudgetNameHelper.getDisplayName(
      name: stats.budget.name,
      categoryNameKey: stats.categoryNameKey,
    );
  }

  Widget _buildFooter(BuildContext context, int pct, Color accent) {
    final scheme = context.ccColorScheme;
    final inPenalty = stats.penaltyTier != BudgetPenaltyTier.none;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CcText(
          el.tr(
            PrjLocaleKeys.budget_percent_used,
            namedArgs: {'percent': '$pct'},
          ),
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: inPenalty
                ? scheme.error
                : scheme.onSurfaceVariant.withOpacity(0.6),
            fontWeight: inPenalty ? FontWeight.bold : null,
          ),
        ),
        CcProgressPie(
          progress: stats.progress,
          color: accent,
          size: context.respDim(20),
        ),
      ],
    );
  }

  Widget _buildIndicatorIcons(
    BuildContext context, {
    required bool hasEditMode,
    required bool showDragHandle,
  }) {
    final rightOffset = hasEditMode
        ? context.respDim(8) + context.respDim(24) + context.respDim(2)
        : context.respDim(8);
    return Positioned(
      top: context.respDim(8),
      right: rightOffset,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stats.status != BudgetLimitStatus.safe) ...[
            Icon(
              stats.status == BudgetLimitStatus.over
                  ? Icons.error_rounded
                  : Icons.warning_amber_rounded,
              color: stats.status == BudgetLimitStatus.over
                  ? context.ccColorScheme.error
                  : PrjColors.warning,
              size: context.respIconSize(baseSize: 14),
            ),
            const CcSpaceXS(),
          ],
          if (stats.budget.hasFixedPrice) ...[
            Icon(
              Icons.bolt_rounded,
              color: context.ccColorScheme.primary,
              size: context.respIconSize(baseSize: 14),
            ),
            if (showDragHandle) const CcSpaceXS(),
          ],
          if (showDragHandle)
            Icon(
              Icons.drag_indicator,
              color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.2),
              size: context.respIconSize(baseSize: 12),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildEditBadges(BuildContext context) {
    final scheme = context.ccColorScheme;
    return [
      Positioned(
        top: context.respDim(-4),
        left: context.respDim(-4),
        child: CcEditBadge(
          icon: Icons.remove,
          color: scheme.error,
          foregroundColor: scheme.onError,
          onTap: onDelete,
        ),
      ),
      Positioned(
        top: context.respDim(-4),
        right: context.respDim(-4),
        child: CcEditBadge(
          icon: Icons.edit,
          color: scheme.primary,
          foregroundColor: scheme.onPrimary,
          onTap: onEdit,
        ),
      ),
    ];
  }

  Color _cardBackgroundColor(BuildContext context, Color? categoryColor) {
    return context.ccColorScheme.primaryContainer.withValues(alpha: 0.1);
  }
}
