import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../domain/entities/cc_device_entity.dart';

/// Centralised service for all device-information queries.
///
/// Reuses the DI-registered [DeviceInfoPlugin] singleton instead of
/// creating ad-hoc instances throughout the codebase.
@lazySingleton
class CcDeviceInfoHelper {
  final DeviceInfoPlugin _deviceInfoPlugin;

  const CcDeviceInfoHelper(this._deviceInfoPlugin);

  /// Builds a complete [CcDeviceEntity] from platform plugins.
  Future<CcDeviceEntity> getDeviceEntity() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceId = await getDeviceId();
    final rawDeviceInfo = await getRawDeviceInfo();

    if (Platform.isAndroid) {
      final android = await _deviceInfoPlugin.androidInfo;
      return CcDeviceEntity(
        deviceInfo: rawDeviceInfo,
        deviceName: android.device,
        deviceId: deviceId,
        osName: 'Android',
        osVersion: android.version.release,
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        packageName: packageInfo.packageName,
        model: android.model,
        brand: android.brand,
        isPhysicalDevice: android.isPhysicalDevice,
      );
    } else if (Platform.isIOS) {
      final ios = await _deviceInfoPlugin.iosInfo;
      return CcDeviceEntity(
        deviceInfo: rawDeviceInfo,
        deviceName: ios.name,
        deviceId: deviceId,
        osName: 'iOS',
        osVersion: ios.systemVersion,
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        packageName: packageInfo.packageName,
        model: ios.model,
        brand: 'Apple',
        isPhysicalDevice: ios.isPhysicalDevice,
      );
    } else {
      return CcDeviceEntity(
        deviceInfo: rawDeviceInfo,
        deviceId: deviceId,
        appName: packageInfo.appName,
        appVersion: packageInfo.version,
        packageName: packageInfo.packageName,
      );
    }
  }

  /// Unique device identifier (vendor ID on iOS, UDID on Android).
  Future<String> getDeviceId() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    } else {
      return await FlutterUdid.udid;
    }
  }

  /// JSON-formatted string with device + app metadata (used by request headers).
  Future<String> getRawDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      final android = await _deviceInfoPlugin.androidInfo;
      final androidId = await FlutterUdid.udid;
      return '{"DeviceName":"${android.device}",'
          '"DeviceID":"$androidId",'
          '"OsName":"ANDROID",'
          '"OsVersion":"${android.bootloader}",'
          '"AppName":"${packageInfo.appName}",'
          '"AppVersion":"${packageInfo.version}",'
          '"UserName":"","LocationInfo":"","Adv":"0"}';
    } else if (Platform.isIOS) {
      final ios = await _deviceInfoPlugin.iosInfo;
      return '{"DeviceName":"${ios.name}",'
          '"DeviceID":"${ios.identifierForVendor!}",'
          '"OsName":"iOS",'
          '"OsVersion":"${ios.systemVersion}",'
          '"AppName":"${packageInfo.appName}",'
          '"AppVersion":"${packageInfo.version}",'
          '"UserName":"","LocationInfo":"","Adv":"0"}';
    }
    return '';
  }

  /// Application version string, e.g. `"1.0.0(code: 1)"`.
  Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid || Platform.isIOS) {
      return '${packageInfo.version}(code: ${packageInfo.buildNumber})';
    }
    return 'unknown';
  }

  /// Whether the iOS hardware is newer than iPhone 8 Plus.
  Future<bool> getDeviceVersion() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        final version = double.parse(
          iosInfo.utsname.machine.split('iPhone')[1],
        );
        return version > 10.5;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
