import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'birth_year_content_sheet.dart';

class BirthYearSheet extends StatelessWidget {
  final int currentYear;
  final int minYear;
  final int maxYear;

  const BirthYearSheet({
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
    return CcAdaptiveBottomSheet.show<int>(
      context: context,
      builder: (context) => BirthYearSheet(
        currentYear: currentYear,
        minYear: minYear,
        maxYear: maxYear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BirthYearContentSheet(
      currentYear: currentYear,
      minYear: minYear,
      maxYear: maxYear,
    );
  }
}
