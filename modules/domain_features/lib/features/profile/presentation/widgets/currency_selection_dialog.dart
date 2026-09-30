import 'package:flutter/material.dart';

import 'currency_selection_dialog_content.dart';

class CurrencySelectionDialog extends StatelessWidget {
  const CurrencySelectionDialog({super.key, required this.initialCurrencyCode});

  final String initialCurrencyCode;

  static Future<String?> show(
    BuildContext context,
    String initialCurrencyCode,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CurrencySelectionDialog(initialCurrencyCode: initialCurrencyCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurrencySelectionDialogContent(
      initialCurrencyCode: initialCurrencyCode,
    );
  }
}
