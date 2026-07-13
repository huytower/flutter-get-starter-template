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
    return showDialog<int>(
      context: context,
      builder: (dialogContext) => BirthYearDialog(
        currentYear: currentYear,
        minYear: minYear,
        maxYear: maxYear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFECEAF6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.respDim(24)),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.respPadding(24),
        vertical: context.respPadding(24),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.respDim(340),
          maxHeight: context.respDim(520),
        ),
        child: BirthYearDialogContent(
          currentYear: currentYear,
          minYear: minYear,
          maxYear: maxYear,
        ),
      ),
    );
  }
}
