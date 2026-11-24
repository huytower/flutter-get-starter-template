import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'currency_selection_content_sheet.dart';

class CurrencySelectionSheet extends StatelessWidget {
  const CurrencySelectionSheet({super.key, required this.initialCurrencyCode});

  final String initialCurrencyCode;

  static Future<String?> show(
    BuildContext context,
    String initialCurrencyCode,
  ) {
    return CcAdaptiveBottomSheet.show<String>(
      context: context,
      // Two columns of tiles need more room than a plain list sheet.
      tabletMaxWidth: 840,
      builder: (context) =>
          CurrencySelectionSheet(initialCurrencyCode: initialCurrencyCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(scaffoldBackgroundColor: Colors.transparent),
      child: CurrencySelectionContentSheet(
        initialCurrencyCode: initialCurrencyCode,
      ),
    );
  }
}
