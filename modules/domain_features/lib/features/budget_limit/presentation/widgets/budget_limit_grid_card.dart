import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
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
  final bool showDragHandle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetLimitGridCard({
    super.key,
    required this.stats,
    this.isEditMode = false,
    this.isDragging = false,
    this.showDragHandle = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        _buildIndicatorIcons(context, isEditMode: isEditMode),

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
                TransactionFormHelpers.formatShort(stats.budget.limit),
                textStyle: context.ccTextTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDisplayName(BuildContext context) {
    if (stats.categoryNameKey != null) {
      final localized = el.tr(stats.categoryNameKey!);
      // Heuristic: if the stored name matches the English translation
      // of the category, we assume it's a default name and should follow
      // the app language.
      if (_isDefaultName(stats.budget.name, stats.categoryNameKey!)) {
        return localized;
      }
    }
    return stats.budget.name;
  }

  /// Returns true if [name] is a known default name for the given [key].
  /// Matches against English hardcoded defaults since those are the most
  /// likely "stale" names when switching to Vietnamese.
  bool _isDefaultName(String name, String key) {
    // Exact match with current translation is always "default"
    if (name == el.tr(key)) return true;

    // Check against English values from en.json
    final enDefaults = {
      'category.food_drink': 'Dining & Coffee',
      'category.gas': 'Gas',
      'category.taxi': 'Taxi',
      'category.parking': 'Parking',
      'category.maintenance': 'Maintenance',
      'category.phone': 'Phone',
      'category.electricity': 'Electricity',
      'category.internet': 'Internet',
      'category.rent': 'Rent',
      'category.condo_fee': 'Condo Fee',
      'category.laundry': 'Laundry',
      'category.furniture': 'Furniture',
      'category.medicine': 'Medicine',
      'category.doctor': 'Doctor',
      'category.gym': 'Gym',
      'category.health_insurance': 'Health Insurance',
      'category.tuition': 'Tuition',
      'category.courses': 'Courses',
      'category.books': 'Books',
      'category.gaming': 'Gaming',
      'category.cinema': 'Cinema',
      'category.events': 'Events',
      'category.travel': 'Travel',
      'category.market_supermarket': 'Market & Supermarket',
      'category.clothing': 'Clothing',
      'category.electronics': 'Electronics',
      'category.cosmetics': 'Cosmetics',
      'category.appliances': 'Appliances',
      'category.gifts': 'Gifts',
      'category.charity': 'Charity',
      'category.religious': 'Religious/Spirituality',
      'category.leisure': 'Leisure & Travel',
      'category.haircut': 'Haircut',
      'category.spa': 'Spa',
      'category.personal_care_product': 'Personal Care',
      'category.bank_fee': 'Bank Fee',
      'category.card_fee': 'Card Annual Fee',
      'category.milk_formula': 'Milk Formula',
      'category.diapers': 'Diapers',
      'category.baby_toys': 'Baby Toys',
    };

    return enDefaults[key] == name;
  }

  Widget _buildFooter(BuildContext context, int pct, Color accent) {
    final scheme = context.ccColorScheme;
    final inPenalty = stats.penaltyTier != BudgetPenaltyTier.none;

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
          progress: stats.progress,
          color: accent,
          size: context.respDim(20),
        ),
      ],
    );
  }

  Widget _buildIndicatorIcons(
    BuildContext context, {
    required bool isEditMode,
  }) {
    // In edit mode the top-right corner is occupied by the edit (pencil)
    // badge, so the fixed-price bolt is shifted left to stay visible.
    final rightOffset = isEditMode
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
          if (stats.budget.isFixedPrice) ...[
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

    return CcBouncing(
      onTap: onTap,
      child: Container(
        width: context.respDim(24),
        height: context.respDim(24),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surface, width: context.respDim(2)),
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
