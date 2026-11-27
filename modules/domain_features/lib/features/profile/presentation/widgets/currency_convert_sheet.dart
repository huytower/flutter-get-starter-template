import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../../core/presentation/widgets/highlighted_guide_row.dart';

/// Confirms changing the primary currency, listing what the one-off
/// conversion of the whole book does (BR §5) as bullets styled like the
/// reconciliation guide.
class CurrencyConvertSheet extends StatelessWidget {
  const CurrencyConvertSheet({super.key, required this.from, required this.to});

  /// Current and new currency codes.
  final String from;
  final String to;

  static const List<({IconData icon, String textKey})> _bullets = [
    (
      icon: Icons.currency_exchange_rounded,
      textKey: PrjLocaleKeys.profile_currency_convert_converted,
    ),
    (
      icon: Icons.edit_note_rounded,
      textKey: PrjLocaleKeys.profile_currency_convert_recorded,
    ),
    (
      icon: Icons.calculate_outlined,
      textKey: PrjLocaleKeys.profile_currency_convert_rounded,
    ),
    (
      icon: Icons.exposure_plus_1_rounded,
      textKey: PrjLocaleKeys.profile_currency_convert_minimum,
    ),
    (
      icon: Icons.warning_amber_rounded,
      textKey: PrjLocaleKeys.profile_currency_convert_irreversible,
    ),
  ];

  /// Opens the sheet; `true` when the user agrees to convert.
  static Future<bool> show(
    BuildContext context, {
    required String from,
    required String to,
  }) async {
    final confirmed = await CcAdaptiveBottomSheet.show<bool>(
      context: context,
      backgroundColor: null,
      builder: (_) => CurrencyConvertSheet(from: from, to: to),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final args = {'from': from, 'to': to};
    // The rows scroll when they do not fit; the title and actions stay.
    return CcPickerSheetFrame(
      title: tr(PrjLocaleKeys.profile_currency_convert_title, namedArgs: args),
      hasScrollableBody: true,
      onConfirm: () => Navigator.of(context).pop(true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.PAGE_MD)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, bullet) in _bullets.indexed) ...[
              if (index > 0) const CcSpaceMD(),
              HighlightedGuideRow(
                icon: bullet.icon,
                text: tr(bullet.textKey, namedArgs: args),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
