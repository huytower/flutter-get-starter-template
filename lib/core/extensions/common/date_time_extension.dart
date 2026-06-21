import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;

extension CcDateTimeExtension on DateTime {
  /// Formats the date time relative to now for dashboard display
  String toDashboardRelativeFormat() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return el.tr(
        difference.inDays == 1
            ? CcLocaleKeys.dashboard_time_day
            : CcLocaleKeys.dashboard_time_days,
        namedArgs: {'count': difference.inDays.toString()},
      );
    }
    if (difference.inHours > 0) {
      return el.tr(
        difference.inHours == 1
            ? CcLocaleKeys.dashboard_time_hour
            : CcLocaleKeys.dashboard_time_hours,
        namedArgs: {'count': difference.inHours.toString()},
      );
    }
    if (difference.inMinutes > 0) {
      return el.tr(
        difference.inMinutes == 1
            ? CcLocaleKeys.dashboard_time_minute
            : CcLocaleKeys.dashboard_time_minutes,
        namedArgs: {'count': difference.inMinutes.toString()},
      );
    }
    return el.tr(CcLocaleKeys.dashboard_time_just_now);
  }
}
