import 'package:flutter/material.dart';

import 'currency_selection_content_sheet.dart';

class CurrencySelectionSheet extends StatelessWidget {
  const CurrencySelectionSheet({super.key, required this.initialCurrencyCode});

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
          CurrencySelectionSheet(initialCurrencyCode: initialCurrencyCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      child: CurrencySelectionContentSheet(
        initialCurrencyCode: initialCurrencyCode,
      ),
    );
  }
}
