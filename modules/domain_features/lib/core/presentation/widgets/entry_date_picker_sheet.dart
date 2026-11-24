import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/presentation/widgets/entry_date_picker_content_sheet.dart';
import 'package:flutter/material.dart';

class EntryDatePickerSheet extends StatelessWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const EntryDatePickerSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return CcAdaptiveBottomSheet.show<DateTime>(
      context: context,
      backgroundColor: null,
      builder: (context) => EntryDatePickerSheet(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EntryDatePickerContentSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }
}
