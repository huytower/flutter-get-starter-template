import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../domain/entities/budget_stats_entity.dart';

/// Budget summary card.
///
/// Swipe left to reveal Edit / Delete action buttons.
/// Background is tinted to match the card's spending state.
class BudgetCard extends StatefulWidget {
  final BudgetStatsEntity stats;
  final VoidCallback? onEditLimit;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.stats,
    this.onEditLimit,
    this.onDelete,
  });

  static const Color _amber = Color(0xFFF2A65A);

  // Total px the card slides left to fully reveal the two action buttons.
  static const double _kRevealWidth = 130.0;

  static String _money(int value) => '${value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )} đ';

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = -d.delta.dx / BudgetCard._kRevealWidth;
    _ctrl.value = (_ctrl.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (velocity < -400 || (_ctrl.value > 0.4 && velocity < 400)) {
      _ctrl.animateTo(1.0, curve: Curves.easeOut);
    } else {
      _ctrl.animateTo(0.0, curve: Curves.easeOut);
    }
  }

  void _close() => _ctrl.animateTo(0.0, curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final status = widget.stats.status;

    final accent = switch (status) {
      BudgetStatus.over => scheme.error,
      BudgetStatus.nearLimit => BudgetCard._amber,
      BudgetStatus.safe => scheme.primary,
    };

    // Blend accent tint against the opaque surface so action buttons behind
    // the card can never show through.
    final bgColor = Color.alphaBlend(accent.withOpacity(0.10), scheme.surface);

    return Container(
      margin: EdgeInsets.only(bottom: context.respDim(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.respDim(16)),
        child: GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Stack(
            children: [
              // Action buttons sit behind and become visible as card slides left.
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionButton(
                      width: BudgetCard._kRevealWidth / 2,
                      color: scheme.primary,
                      icon: Icons.edit_outlined,
                      label: el.tr(CcLocaleKeys.common_edit),
                      onTap: () {
                        _close();
                        widget.onEditLimit?.call();
                      },
                    ),
                    _ActionButton(
                      width: BudgetCard._kRevealWidth / 2,
                      color: scheme.error,
                      icon: Icons.delete_outline,
                      label: el.tr(CcLocaleKeys.common_delete),
                      onTap: () {
                        _close();
                        widget.onDelete?.call();
                      },
                    ),
                  ],
                ),
              ),
              // Card content — translates left on drag.
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Transform.translate(
                  offset: Offset(-_ctrl.value * BudgetCard._kRevealWidth, 0),
                  child: child,
                ),
                child: _buildCardContent(context, accent, bgColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
      BuildContext context, Color accent, Color bgColor) {
    final scheme = context.ccColorScheme;
    final status = widget.stats.status;
    final highlighted = status != BudgetStatus.safe;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            widget.stats.budget.name,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const CcSpaceSM(),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.respDim(8)),
            child: LinearProgressIndicator(
              value: widget.stats.progress,
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
                '${BudgetCard._money(widget.stats.spent)} / ${BudgetCard._money(widget.stats.budget.limit)}',
                textStyle: context.ccTextTheme.bodySmall,
              ),
              CcText(
                widget.stats.isOver
                    ? el.tr(CcLocaleKeys.budget_over_by,
                        namedArgs: {
                          'amount': BudgetCard._money(
                              widget.stats.spent - widget.stats.budget.limit)
                        })
                    : el.tr(CcLocaleKeys.budget_remaining,
                        namedArgs: {
                          'amount':
                              BudgetCard._money(widget.stats.remaining)
                        }),
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

  Widget _buildWarning(
      BuildContext context, BudgetStatus status, Color accent) {
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
}

class _ActionButton extends StatelessWidget {
  final double width;
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.width,
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: context.respIconSize(baseSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.respFontSize(11),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
