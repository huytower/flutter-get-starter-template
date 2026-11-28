import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/presentation/widgets/highlighted_guide_row.dart';

/// Confirms deleting a liability position, listing what the delete does as
/// bullets: linked debt entries go too, wallet balances update, liability totals
/// change, and reconciled entries are preserved.
class LiabilityDeleteSheet extends StatelessWidget {
  const LiabilityDeleteSheet({super.key});

  static const List<({IconData icon, String textKey})> _bullets = [
    (
      icon: Icons.receipt_long_outlined,
      textKey: PrjLocaleKeys.liability_delete_entries,
    ),
    (
      icon: Icons.account_balance_wallet_outlined,
      textKey: PrjLocaleKeys.liability_delete_balances,
    ),
    (
      icon: Icons.trending_down_rounded,
      textKey: PrjLocaleKeys.liability_delete_totals,
    ),
    (
      icon: Icons.lock_outline_rounded,
      textKey: PrjLocaleKeys.liability_delete_reconciled,
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
      builder: (_) =>
          const SingleChildScrollView(child: LiabilityDeleteSheet()),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CcConfirmSheet(
      icon: Icons.delete_outline_rounded,
      title: tr(PrjLocaleKeys.liability_delete_title),
      message: "",
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
