import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/currency/money_formatter.dart';
import '../../domain/entities/budget_limit_stats_entity.dart';

/// Back-side detail widget for a budget limit item shown upon card flip.
///
/// Designed to match the card UI style of [LiabilityWalletGridCard] /
/// [LendWalletListItem] while fitting the exact same bounds as [BudgetLimitGridCard].
class BudgetLimitGridCardDetail extends StatelessWidget {
  final BudgetLimitStatsEntity stats;
  final bool hasEditMode;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetLimitGridCardDetail({
    super.key,
    required this.stats,
    this.hasEditMode = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final iconColor = stats.color ?? scheme.primary;

    final iconData = stats.iconCode > 0
        ? iconDataFromCode(stats.iconCode, fontFamily: stats.iconFamily)
        : Icons.savings;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: CcGlassyGradientBackground()),
        _buildMainCard(context, iconColor, iconData),
        if (hasEditMode) ..._buildEditBadges(context),
      ],
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    Color iconColor,
    IconData iconData,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(context.respDim(12)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: context.brLg,
        border: context.borderSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAmountSection(context),
          CcDividerLine(color: scheme.onSurface.withOpacity(0.08)),
          _buildSpentRow(context),
          _buildLimitRow(context),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final scheme = context.ccColorScheme;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: CcText(
        formatCurrencyWithSymbol(
          stats.remaining.abs(),
          currencyCode: stats.budget.currencyCode,
        ),
        maxLines: 1,
        align: Alignment.center,
        textAlign: TextAlign.center,
        textStyle: context.ccTextTheme.headlineSmall?.copyWith(
          fontWeight: CcTypographyParams.bold,
          color: stats.remaining < 0 ? scheme.error : scheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSpentRow(BuildContext context) {
    return _buildMetricRow(
      context,
      assetPath: 'assets/icon/ic_repay.webp',
      prefix: el.tr(PrjLocaleKeys.budget_spent_prefix),
      amount: stats.spent,
    );
  }

  Widget _buildLimitRow(BuildContext context) {
    return _buildMetricRow(
      context,
      assetPath: 'assets/icon/ic_borrow.webp',
      prefix: el.tr(PrjLocaleKeys.budget_limit_prefix),
      amount: stats.budget.limit,
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String assetPath,
    required String prefix,
    required int amount,
  }) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Image.asset(
          assetPath,
          color: scheme.primary,
          width: context.respIconSize(baseSize: 18),
          height: context.respIconSize(baseSize: 18),
        ),
        const CcSpaceXS(),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              maxLines: 1,
              text: TextSpan(
                style: context.ccTextTheme.labelSmall?.copyWith(
                  color: scheme.onSurface,
                ),
                children: [
                  TextSpan(text: '$prefix: '),
                  TextSpan(
                    text: formatCurrencyWithSymbol(
                      amount,
                      currencyCode: stats.budget.currencyCode,
                    ),
                    style: context.ccTextTheme.labelSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: CcTypographyParams.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
}
