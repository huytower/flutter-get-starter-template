import 'package:easy_localization/easy_localization.dart' as el;
import 'package:message/export_message.dart';

/// Formats the days of an audit cycle for the reconciliation sheets.
abstract final class AuditDayFormatter {
  /// The weekday name from the app's own translations ("Chủ Nhật", "Sun").
  static String weekday(DateTime day) {
    final names = el.tr(PrjLocaleKeys.common_weekday_names).split('|');
    return names.length == 7 ? names[day.weekday - 1] : '';
  }

  /// "Thứ Bảy, 28/11": the weekday name and the day/month pattern the rest of
  /// the app uses.
  static String dayWithDate(DateTime day) {
    final name = weekday(day);
    final date = el.DateFormat('dd/MM').format(day);
    return name.isEmpty ? date : '$name, $date';
  }
}
