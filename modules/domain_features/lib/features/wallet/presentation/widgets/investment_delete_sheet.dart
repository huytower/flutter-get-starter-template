import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/presentation/widgets/highlighted_guide_row.dart';

/// Confirms deleting an investment position, listing what the delete does as
/// bullets (BR §9): linked entries go too, money moves back to the wallet,
/// ROI changes, and reconciled entries block it.
class InvestmentDeleteSheet extends StatelessWidget {
  const InvestmentDeleteSheet({super.key});

  static const List<({IconData icon, String textKey})> _bullets = [
    (
      icon: Icons.receipt_long_outlined,
      textKey: PrjLocaleKeys.wallet_investment_delete_entries,
    ),
    (
      icon: Icons.account_balance_wallet_outlined,
      textKey: PrjLocaleKeys.wallet_investment_delete_refund,
    ),
    (
      icon: Icons.remove_circle_outline_rounded,
      textKey: PrjLocaleKeys.wallet_investment_delete_returns,
    ),
    (
      icon: Icons.trending_down_rounded,
      textKey: PrjLocaleKeys.wallet_investment_delete_roi,
    ),
    (
      icon: Icons.lock_outline_rounded,
      textKey: PrjLocaleKeys.wallet_investment_delete_reconciled,
    ),
  ];

  /// Opens the sheet; `true` when the user confirms the delete.
  static Future<bool> show(BuildContext context) async {
    final confirmed = await CcAdaptiveBottomSheet.show<bool>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Scroll-controlled with its own scroll view: the bullets may be taller
      // than the default half-height sheet on small phones.
      builder: (_) => const SingleChildScrollView(
        child: InvestmentDeleteSheet(),
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CcConfirmSheet(
      icon: Icons.delete_outline_rounded,
      title: tr(PrjLocaleKeys.wallet_investment_delete_title),
      message: tr(PrjLocaleKeys.wallet_investment_delete_intro),
      confirmLabel: tr(PrjLocaleKeys.common_delete),
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, bullet) in _bullets.indexed) ...[
            if (index > 0) const CcSpaceMD(),
            HighlightedGuideRow(icon: bullet.icon, text: tr(bullet.textKey)),
          ],
        ],
      ),
    );
  }
}
