import 'package:cc_micro_features/export_micro_features.dart'
    show LanguagePickerSheet;
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../category/export_category.dart';
import '../widgets/currency_selection_sheet.dart';

/// The pickers the profile screen opens; each returns the user's choice or
/// null when dismissed.
abstract final class ProfileSheets {
  /// Longest display name.
  static const int _displayNameMaxLength = 20;

  /// Ages 10–70; starts at [current] or 25 years ago.
  static Future<int?> birthYear(BuildContext context, int? current) {
    final year = DateTime.now().year;
    final minYear = year - 70;
    final maxYear = year - 10;
    return CcYearPickerSheet.show(
      context,
      title: el.tr(PrjLocaleKeys.profile_birth_year_hint),
      initialYear: (current ?? year - 25).clamp(minYear, maxYear),
      firstYear: minYear,
      lastYear: maxYear,
    );
  }

  /// Returns the picked 0-based day index (0 = Monday).
  static Future<int?> weeklyAuditDay(
    BuildContext context,
    int currentIndex,
  ) async {
    final weekday = await CcWeekdayPickerSheet.show(
      context,
      title: el.tr(PrjLocaleKeys.profile_weekly_audit_day_hint),
      // "Thứ Hai|Thứ Ba|...", Monday first.
      weekdayNames: el.tr(PrjLocaleKeys.common_weekday_names).split('|'),
      initialWeekday: currentIndex + DateTime.monday,
    );
    return weekday == null ? null : weekday - DateTime.monday;
  }

  /// Returns the trimmed new name, or null when dismissed or left empty.
  static Future<String?> displayName(BuildContext context, String current) {
    return CcTextInputSheet.show(
      context,
      title: el.tr(PrjLocaleKeys.profile_display_name_title),
      hint: el.tr(PrjLocaleKeys.profile_display_name_hint),
      confirmLabel: el.tr(PrjLocaleKeys.profile_display_name_save),
      initialValue: current,
      maxLength: _displayNameMaxLength,
    );
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
