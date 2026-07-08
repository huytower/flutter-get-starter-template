import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/profile_settings_entity.dart';
import '../../domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/usecases/update_profile_settings_usecase.dart';

@lazySingleton
class ProfileController extends GetxController {
  ProfileController(
    this._getSettings,
    this._updateSettings,
    this._session,
    this._deviceInfo,
    this._authCoordinator,
  );

  final GetProfileSettingsUseCase _getSettings;
  final UpdateProfileSettingsUseCase _updateSettings;
  final SessionContract _session;
  final CcDeviceInfoHelper _deviceInfo;
  final AuthCoordinator _authCoordinator;

  final Rx<ProfileSettingsEntity> settings = const ProfileSettingsEntity().obs;
  final RxString appVersion = ''.obs;

  Stream<CcUserEntity?> get userStream => _session.userStream;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final s = await _getSettings();
    settings.value = s;
    appVersion.value = await _deviceInfo.getAppVersion();
  }

  Future<void> toggleReminder(bool value) async {
    final updated = settings.value.copyWith(reminderEnabled: value);
    settings.value = updated;
    await _updateSettings(updated);
  }

  Future<void> logout(BuildContext context) async {
    await _session.clearSession();
    if (context.mounted) _authCoordinator.navigateToLogin(context);
  }
}
