import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications` for the app's on-device
/// reminders (weekly audit, Cloud-backup nudge, loan due dates). These are
/// all locally scheduled — separate from the existing Firebase Messaging
/// setup, which handles server-pushed notifications.
@lazySingleton
class NotificationService {
  static const String _channelId = 'reminders_channel';
  // Channel name/description are OS-level metadata (Android Settings ->
  // Apps -> Notifications), not in-app UI, but still user-facing text, so
  // still routed through el.tr() rather than hardcoded. Safe to call here:
  // main.dart only triggers init() (which creates the channel) after the
  // parallel boot barrier that includes CcLocalization.initialize().
  static String get _channelName =>
      el.tr(CcLocaleKeys.notification_channel_name);
  static String get _channelDescription =>
      el.tr(CcLocaleKeys.notification_channel_description);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void>? _initFuture;

  /// Idempotent and safe to call concurrently — repeated/overlapping calls
  /// all await the same underlying initialization.
  Future<void> init() => _initFuture ??= _doInit();

  Future<void> _doInit() async {
    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz.identifier));
    } catch (_) {
      // Falls back to the timezone package's default (UTC) if the
      // platform's IANA id can't be resolved — reminders may then fire at
      // an offset hour rather than not at all.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested explicitly via permission_handler
        // (requestPermission below), so the OS-native prompts here are
        // disabled to avoid a duplicate iOS permission dialog.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
          ),
        );
  }

  /// Requests POST_NOTIFICATIONS (Android 13+) / iOS alert permission,
  /// mirroring `CcLocationHelper`'s request-on-demand pattern. Skips the
  /// native prompt if already granted or permanently denied.
  Future<bool> requestPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  /// Schedules a local notification at [dateTime] (device-local). No-ops if
  /// [dateTime] has already passed or notification permission is denied.
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;
    await init();
    if (!await requestPermission()) return;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Shows a notification immediately. No-op if permission is denied.
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    if (!await requestPermission()) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
