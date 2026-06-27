import 'package:cc_sdk_data/domain/entities/cc_device_entity.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/cc_device_info_helper.dart';

/// Registers third-party dependencies that cannot be auto-registered
/// (they don't have injectable constructors we control).
@module
abstract class CcSdkDependencies {
  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @singleton
  InternetConnection get internetConnection => InternetConnection();

  @singleton
  Connectivity get connectivity => Connectivity();

  @singleton
  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();

  /// Centralized provider for device model, moved from infrastructure_module.dart
  @preResolve
  @singleton
  Future<CcDeviceEntity> deviceModel(CcDeviceInfoHelper deviceInfoHelper) =>
      deviceInfoHelper.getDeviceEntity();
}
