import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'birth_year_dialog_content.dart';

class BirthYearDialog extends StatelessWidget {
  final int currentYear;
  final int minYear;
  final int maxYear;

  const BirthYearDialog({
    super.key,
    required this.currentYear,
    required this.minYear,
    required this.maxYear,
  });

  static Future<int?> show(
    BuildContext context, {
    required int currentYear,
    required int minYear,
    required int maxYear,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BirthYearDialog(
        currentYear: currentYear,
        minYear: minYear,
        maxYear: maxYear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BirthYearDialogContent(
      currentYear: currentYear,
      minYear: minYear,
      maxYear: maxYear,
    );
  }
}
