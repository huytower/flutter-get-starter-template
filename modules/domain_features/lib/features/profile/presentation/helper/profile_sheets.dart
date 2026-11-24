import 'package:cc_micro_features/export_micro_features.dart'
    show LanguagePickerSheet;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../category/export_category.dart';
import '../widgets/birth_year_sheet.dart';
import '../widgets/currency_selection_sheet.dart';
import '../widgets/display_name_sheet.dart';
import '../widgets/weekly_audit_day_sheet.dart';

/// The pickers the profile screen opens; each returns the user's choice or
/// null when dismissed.
abstract final class ProfileSheets {
  /// Ages 10–70; starts at [current] or 25 years ago.
  static Future<int?> birthYear(BuildContext context, int? current) {
    final year = DateTime.now().year;
    final minYear = year - 70;
    final maxYear = year - 10;
    return BirthYearSheet.show(
      context,
      currentYear: (current ?? year - 25).clamp(minYear, maxYear),
      minYear: minYear,
      maxYear: maxYear,
    );
  }

  /// Returns the picked 0-based day index (0 = Monday).
  static Future<int?> weeklyAuditDay(
    BuildContext context,
    int currentIndex,
  ) async {
    final day = await WeeklyAuditDaySheet.show(
      context,
      currentDay: currentIndex + 1,
    );
    return day == null ? null : day - 1;
  }

  /// Returns the trimmed new name, or null when dismissed or left empty.
  static Future<String?> displayName(
    BuildContext context,
    String current,
  ) async {
    final name = (await DisplayNameSheet.show(
      context,
      currentName: current,
    ))?.trim();
    return name == null || name.isEmpty ? null : name;
  }

  static Future<String?> currency(BuildContext context, String current) =>
      CurrencySelectionSheet.show(context, current);

  /// Applies the picked app language; category labels re-translate.
  static Future<void> language(BuildContext context) async {
    final picked = await LanguagePickerSheet.show(
      context,
      locales: PrjLocalization.supportedLocales,
    );
    if (picked == null || !context.mounted) return;
    await el.EasyLocalization.of(context)!.setLocale(picked);
    CategorySettingsController.onCategoriesChanged.value++;
  }
}
