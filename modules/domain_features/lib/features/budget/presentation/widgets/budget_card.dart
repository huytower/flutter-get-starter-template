import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/budget_stats_entity.dart';

/// Budget summary card with a progress bar and a three-state warning:
/// safe → near-limit (amber) → over-limit (red).
class BudgetCard extends StatelessWidget {
  final BudgetStatsEntity stats;
  final VoidCallback? onEditLimit;
  final VoidCallback? onReset;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.stats,
    this.onEditLimit,
    this.onReset,
    this.onDelete,
  });

  /// Amber used for the near-limit state (matches the report palette).
  static const Color _amber = Color(0xFFF2A65A);

  static String _money(int value) =>
      '${value.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")} đ';

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final status = stats.status;

    final accent = switch (status) {
      BudgetStatus.over => scheme.error,
      BudgetStatus.nearLimit => _amber,
      BudgetStatus.safe => scheme.primary,
    };
    final highlighted = status != BudgetStatus.safe;

    return Container(
      margin: EdgeInsets.only(bottom: context.respDim(12)),
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.respDim(16)),
        border: Border.all(
          color: highlighted ? accent : scheme.outlineVariant,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CcText(
                  stats.budget.name,
                  textStyle: context.ccTextTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildMenu(context),
            ],
          ),
          const CcSpaceSM(),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.respDim(8)),
            child: LinearProgressIndicator(
              value: stats.progress,
              minHeight: context.respDim(8),
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const CcSpaceSM(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                '${_money(stats.spent)} / ${_money(stats.budget.limit)}',
                textStyle: context.ccTextTheme.bodySmall,
              ),
              CcText(
                stats.isOver
                    ? el.tr(CcLocaleKeys.budget_over_by, namedArgs: {'amount': _money(stats.spent - stats.budget.limit)})
                    : el.tr(CcLocaleKeys.budget_remaining, namedArgs: {'amount': _money(stats.remaining)}),
                textStyle: context.ccTextTheme.bodySmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (highlighted) ...[
            const CcSpaceSM(),
            _buildWarning(context, status, accent),
          ],
        ],
      ),
    );
  }

  Widget _buildWarning(BuildContext context, BudgetStatus status, Color accent) {
    return Row(
      children: [
        Icon(
          status == BudgetStatus.over
              ? Icons.error_outline_rounded
              : Icons.warning_amber_rounded,
          size: context.respIconSize(baseSize: 16),
          color: accent,
        ),
        const CcSpaceXS(),
        CcText(
          status == BudgetStatus.over
              ? el.tr(CcLocaleKeys.budget_over_limit)
              : el.tr(CcLocaleKeys.budget_near_limit),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: context.ccColorScheme.onSurfaceVariant),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEditLimit?.call();
            break;
          case 'reset':
            onReset?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text(el.tr(CcLocaleKeys.budget_edit_limit))),
        PopupMenuItem(value: 'reset', child: Text(el.tr(CcLocaleKeys.budget_reset_period))),
        PopupMenuItem(value: 'delete', child: Text(el.tr(CcLocaleKeys.common_delete))),
      ],
    );
  }
}
