import 'package:flutter/material.dart';

import '../../features/transaction/presentation/widgets/transaction_date_picker_dialog.dart';
import 'money_format_helper.dart';

/// Common helper functions for transaction forms.
/// State-management agnostic - pure functions only.
class TransactionFormHelpers {
  /// Format amount string for display (e.g., "1000000" -> "1.000.000")
  static String formatAmount(String amount, {String currencyCode = 'VND'}) {
    return MoneyFormatter.formatInput(amount, currencyCode: currencyCode);
  }

  /// Pick a date using the custom date picker dialog.
  /// Returns the selected date or null if cancelled.
  static Future<DateTime?> pickDate(
    BuildContext context,
    DateTime initialDate, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final picked = await TransactionDatePickerDialog.show(
      context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(now.year, now.month - 6, now.day),
      lastDate: lastDate ?? now,
    );
    return picked;
  }

  /// Update date while preserving the time component.
  static DateTime updateDatePreserveTime(DateTime original, DateTime newDate) {
    return DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      original.hour,
      original.minute,
    );
  }

  /// Compose note from controller, returning null if empty.
  static String? composeNote(TextEditingController controller) {
    final note = controller.text.trim();
    return note.isEmpty ? null : note;
  }

  /// Format amount to short representation (e.g., 1000000 -> "1tr", 50000 -> "50k")
  static String formatShort(
    num amount, {
    bool useFullSuffix = false,
    String currencyCode = 'VND',
  }) {
    return formatVndShort(
      amount,
      useFullSuffix: useFullSuffix,
      currencyCode: currencyCode,
    );
  }
}
