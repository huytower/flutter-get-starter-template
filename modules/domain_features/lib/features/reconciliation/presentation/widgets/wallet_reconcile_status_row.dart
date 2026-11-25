import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/currency/money_formatter.dart';

/// Status line under a wallet being reconciled: not counted, matched, or
/// off by an amount with "create adjustment" / done and a review button.
class WalletReconcileStatusRow extends StatelessWidget {
  final bool hasCounted;
  final bool hasBalanced;
  final bool hasAcknowledged;
  final int diff;
  final String currencyCode;
  final Color statusColor;
  final VoidCallback onAcknowledge;
  final VoidCallback onReview;

  /// Puts the actions (create adjustment / review) on their own line, bottom
  /// right, so a large "Off by" amount never competes with them for width.
  final bool stacked;

  const WalletReconcileStatusRow({
    super.key,
    required this.hasCounted,
    required this.hasBalanced,
    required this.hasAcknowledged,
    required this.diff,
    required this.currencyCode,
    required this.statusColor,
    required this.onAcknowledge,
    required this.onReview,
    this.stacked = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    if (!hasCounted) {
      return Row(
        children: [
          Icon(
            Icons.radio_button_unchecked_rounded,
            size: context.respIconSize(baseSize: 16),
            color: scheme.onSurfaceVariant,
          ),
          const CcSpaceXS(),
          CcText(
            el.tr(PrjLocaleKeys.reconciliation_not_counted),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (hasBalanced) {
      return Row(
        children: [
          const CcIconToken(Icons.check_circle_outline, size: 16),
          const CcSpaceXS(),
          CcText(
            el.tr(PrjLocaleKeys.reconciliation_matched),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final status = Row(
      children: [
        Icon(
          hasAcknowledged ? Icons.check_circle_outline : Icons.error_outline,
          color: statusColor,
          size: 16,
        ),
        const CcSpaceXS(),
        CcText(
          el.tr(
            PrjLocaleKeys.reconciliation_lech,
            namedArgs: {
              'amount':
                  '${diff > 0 ? '+' : ''}${diff < 0 ? '-' : ''}${formatCurrencyWithSymbol(diff.abs(), currencyCode: currencyCode)}',
            },
          ),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!hasAcknowledged)
          CcBouncing(
            onTap: onAcknowledge,
            child: CcText(
              el.tr(PrjLocaleKeys.reconciliation_create_adjustment),
              textStyle: context.ccTextTheme.bodySmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: scheme.error,
              ),
            ),
          )
        else
          CcText(
            el.tr(PrjLocaleKeys.common_done),
            textStyle: context.ccTextTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        CcIconButton.bouncing(
          icon: Icon(
            Icons.fact_check_outlined,
            size: context.respIconSize(baseSize: 16),
            color: scheme.onSurfaceVariant,
          ),
          height: context.respDim(28),
          width: context.respDim(28),
          tooltip: el.tr(PrjLocaleKeys.reconciliation_review_transactions),
          onTap: onReview,
        ),
      ],
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          status,
          const CcSpaceXS(),
          Align(alignment: Alignment.centerRight, child: actions),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [status, actions],
    );
  }
}
