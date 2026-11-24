import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

import '../../../notification/notification_service.dart';
import '../../domain/entities/profile_settings_entity.dart';
import '../../domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/usecases/update_profile_settings_usecase.dart';

/// Reads and saves the profile settings, plus the side effects a settings
/// change needs outside the profile (notification permission, app theme).
@injectable
class ProfileSettingsActions {
  ProfileSettingsActions(
    this._getSettings,
    this._updateSettings,
    this._notificationService,
    this._themeProvider,
    this._deviceInfo,
  );

  final GetProfileSettingsUseCase _getSettings;
  final UpdateProfileSettingsUseCase _updateSettings;
  final NotificationService _notificationService;
  final ThemeProvider _themeProvider;
  final CcDeviceInfoService _deviceInfo;

  Future<ProfileSettingsEntity> load() => _getSettings();

  Future<void> save(ProfileSettingsEntity settings) =>
      _updateSettings(settings);

  /// True when the user allowed notifications (needed for reminders).
  Future<bool> requestReminderPermission() =>
      _notificationService.requestPermission();

  void applyTheme({required bool isDarkMode}) =>
      _themeProvider.toggleTheme(isDarkMode);

  Future<String> appVersion() => _deviceInfo.getAppVersion();

  static const String _signInReminderDismissedKey =
      'profile_sign_in_reminder_dismissed';

  /// Once dismissed, the sign-in reminder never comes back.
  Future<bool> isSignInReminderDismissed() async =>
      (await SharedPreferences.getInstance()).getBool(
        _signInReminderDismissedKey,
      ) ??
      false;

  Future<void> dismissSignInReminder() async =>
      (await SharedPreferences.getInstance()).setBool(
        _signInReminderDismissedKey,
        true,
      );
}
