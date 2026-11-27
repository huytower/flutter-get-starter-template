import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/presentation/widgets/highlighted_guide_row.dart';

/// Explains why a reconciled transaction has no edit/delete (BR §4.B) and how
/// to correct it, as bullets styled like the reconciliation guide.
class ReconciledTransactionSheet extends StatelessWidget {
  const ReconciledTransactionSheet({super.key});

  static const List<({IconData icon, String textKey})> _bullets = [
    (
      icon: Icons.lock_outline_rounded,
      textKey: PrjLocaleKeys.transaction_reconciled_info_closed,
    ),
    (
      icon: Icons.account_balance_wallet_outlined,
      textKey: PrjLocaleKeys.transaction_reconciled_info_balances,
    ),
    (
      icon: Icons.add_circle_outline_rounded,
      textKey: PrjLocaleKeys.transaction_reconciled_info_offset,
    ),
  ];

  static Future<void> show(BuildContext context) =>
      CcAdaptiveBottomSheet.show<void>(
        context: context,
        backgroundColor: null,
        builder: (_) => const ReconciledTransactionSheet(),
      );

  @override
  Widget build(BuildContext context) {
    // The rows scroll when they do not fit; the title and OK stay in view.
    return CcPickerSheetFrame(
      title: tr(PrjLocaleKeys.transaction_reconciled_title),
      hasScrollableBody: true,
      hasCancel: false,
      onConfirm: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_MD)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, bullet) in _bullets.indexed) ...[
              if (index > 0) const CcSpaceMD(),
              HighlightedGuideRow(icon: bullet.icon, text: tr(bullet.textKey)),
            ],
          ],
        ),
      ),
    );
  }
}
