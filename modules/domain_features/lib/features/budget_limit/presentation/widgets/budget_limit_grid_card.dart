import 'dart:math' as math;

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';
import 'budget_limit_grid_card_detail.dart';
import 'budget_limit_pie_chart.dart';

/// Grid card for a budget item — uses the exact same 3D flip card effect as [ProfilePageHeader]
/// to reveal [BudgetLimitGridCardDetail].
///
/// View mode: tapping flips between front summary and back detail layout; holding 300ms allows drag-to-reorder.
/// Edit mode: shows red (−) delete and primary edit badges; drag handle and flip are disabled.
class BudgetLimitGridCard extends StatefulWidget {
  final BudgetLimitStatsEntity stats;
  final bool isEditMode;
  final bool isDragging;
  final bool showDragHandle;
  final bool isFlippable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetLimitGridCard({
    super.key,
    required this.stats,
    this.isEditMode = false,
    this.isDragging = false,
    this.showDragHandle = true,
    this.isFlippable = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<BudgetLimitGridCard> createState() => _BudgetLimitGridCardState();
}

class _BudgetLimitGridCardState extends State<BudgetLimitGridCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (widget.isEditMode || !widget.isFlippable || _controller.isAnimating) {
      return;
    }

    if (_isFrontVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFrontVisible = !_isFrontVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFlippable) {
      return _buildFrontCard(context);
    }

    return GestureDetector(
      onTap: _toggleFlip,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isUnder = angle > (math.pi / 2);

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isUnder
                ? Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: BudgetLimitGridCardDetail(
                      stats: widget.stats,
                      isEditMode: widget.isEditMode,
                      onEdit: widget.onEdit,
                      onDelete: widget.onDelete,
                    ),
                  )
                : _buildFrontCard(context),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    final stats = widget.stats;
    final isEditMode = widget.isEditMode;
    final showDragHandle = widget.showDragHandle;

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
          isEditMode: isEditMode,
          showDragHandle: showDragHandle,
        ),

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
        color: _cardBackgroundColor(context, widget.stats.color),
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
                    widget.stats.budget.limit,
                    currencyCode: widget.stats.budget.currencyCode,
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
      name: widget.stats.budget.name,
      categoryNameKey: widget.stats.categoryNameKey,
    );
  }

  Widget _buildFooter(BuildContext context, int pct, Color accent) {
    final scheme = context.ccColorScheme;
    final inPenalty = widget.stats.penaltyTier != BudgetPenaltyTier.none;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CcText(
          el.tr(
            CcLocaleKeys.budget_percent_used,
            namedArgs: {'percent': '$pct'},
          ),
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: inPenalty
                ? scheme.error
                : scheme.onSurfaceVariant.withOpacity(0.6),
            fontWeight: inPenalty ? FontWeight.bold : null,
          ),
        ),
        BudgetLimitPieChart(
          progress: widget.stats.progress,
          color: accent,
          size: context.respDim(20),
        ),
      ],
    );
  }

  Widget _buildIndicatorIcons(
    BuildContext context, {
    required bool isEditMode,
    required bool showDragHandle,
  }) {
    final rightOffset = isEditMode
        ? context.respDim(8) + context.respDim(24) + context.respDim(2)
        : context.respDim(8);
    return Positioned(
      top: context.respDim(8),
      right: rightOffset,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.stats.status != BudgetLimitStatus.safe) ...[
            Icon(
              widget.stats.status == BudgetLimitStatus.over
                  ? Icons.error_rounded
                  : Icons.warning_amber_rounded,
              color: widget.stats.status == BudgetLimitStatus.over
                  ? context.ccColorScheme.error
                  : PrjColors.warning,
              size: context.respIconSize(baseSize: 14),
            ),
            const CcSpaceXS(),
          ],
          if (widget.stats.budget.isFixedPrice) ...[
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
          onTap: widget.onDelete,
        ),
      ),
      Positioned(
        top: context.respDim(-4),
        right: context.respDim(-4),
        child: CcEditBadge(
          icon: Icons.edit,
          color: scheme.primary,
          foregroundColor: scheme.onPrimary,
          onTap: widget.onEdit,
        ),
      ),
    ];
  }

  Color _cardBackgroundColor(BuildContext context, Color? categoryColor) {
    return context.ccColorScheme.primaryContainer.withValues(alpha: 0.1);
  }
}
