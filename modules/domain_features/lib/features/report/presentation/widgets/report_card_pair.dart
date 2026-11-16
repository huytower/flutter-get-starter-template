import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Lays out one or two report cards (e.g. expense | income).
///
/// Phones and portrait tablets stack them with the usual spacing. On a
/// landscape tablet ([CcTwoColumn.shouldUse]) they sit side by side, left and
/// right, each taking half the row; a lone card keeps its half instead of
/// stretching across the whole row.
class ReportCardPair extends StatelessWidget {
  const ReportCardPair({super.key, required this.cards});

  /// One or two cards, in left-to-right / top-to-bottom order.
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    if (!CcTwoColumn.shouldUse(context)) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const CcSpaceLG(),
            cards[i],
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: cards.first),
        const CcSpaceLG(),
        Expanded(child: cards.length > 1 ? cards[1] : const SizedBox.shrink()),
      ],
    );
  }
}
