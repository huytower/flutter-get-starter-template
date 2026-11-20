import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:message/export_message.dart';

/// Text and numbers the profile screen shows, derived from plain values.
abstract final class ProfileDisplayText {
  /// Full name, else email, else phone, else "Guest".
  static String displayName(CcUserEntity? user) {
    if (user == null) return el.tr(CcLocaleKeys.profile_guest);
    final name = fullName(user);
    if (name.isNotEmpty) return name;
    if (user.email.isNotEmpty) return user.email;
    return user.phoneNumber ?? el.tr(CcLocaleKeys.profile_guest);
  }

  static String fullName(CcUserEntity? user) => [
    user?.firstName,
    user?.lastName,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

  /// Days until the next audit weekday ([auditDayIndex] 0 = Monday); 0 when
  /// [today] is the audit day.
  static int daysToNextAudit(int auditDayIndex, DateTime today) =>
      (auditDayIndex + 1 - today.weekday) % 7;

  static String weeklyAuditDayName(int auditDayIndex) {
    final names = el.tr(CcLocaleKeys.common_weekday_names).split('|');
    return auditDayIndex >= 0 &&
            auditDayIndex < 7 &&
            auditDayIndex < names.length
        ? names[auditDayIndex]
        : '';
  }

  static String languageName(String languageCode) => switch (languageCode) {
    'vi' => el.tr(CcLocaleKeys.settings_language_vietnamese),
    'ko' => el.tr(CcLocaleKeys.settings_language_korean),
    'ja' => el.tr(CcLocaleKeys.settings_language_japanese),
    'zh' => el.tr(CcLocaleKeys.settings_language_chinese),
    _ => el.tr(CcLocaleKeys.settings_language_english),
  };
}
