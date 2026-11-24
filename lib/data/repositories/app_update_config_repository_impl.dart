import 'package:app_config/core/config/http/http_client/http_client_config.dart';
import 'package:cc_micro_features/export_micro_features.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

/// Supplies the `app_update` micro-feature with this app's update policy.
///
/// Source of truth is **Firebase Remote Config**, so the policy reaches
/// builds that are already installed:
/// - `isForce` (Boolean) — turns the forced update on.
/// - `minimumOsVersionHasForce` (String, semver app version, e.g. `1.2.0`) —
///   installed versions below it must update.
///
/// The env values (`IS_FORCE_UPDATE`, `MINIMUM_OS_VERSION_HAS_FORCE`, filled by
/// CI from GitHub secrets) are only the in-app defaults: used before the first
/// successful fetch, offline, or when a key is missing in Remote Config.
@LazySingleton(as: AppUpdateConfigRepository)
class AppUpdateConfigRepositoryImpl implements AppUpdateConfigRepository {
  static const forceUpdateConfigKey = 'isForce';
  static const minimumVersionKey = 'minimumOsVersionHasForce';

  /// App Store id of this app (also used by the in-app rating link).
  static const _iosAppStoreId = '6738361005';

  Future<FirebaseRemoteConfig>? _ready;

  /// Sets defaults and fetches once per app session; later calls reuse it.
  Future<FirebaseRemoteConfig> _remoteConfig() => _ready ??= _setUp();

  Future<FirebaseRemoteConfig> _setUp() async {
    final env = HttpClientConfig.httpConfig;
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults({
      forceUpdateConfigKey: env.hasForceUpdate,
      minimumVersionKey: env.minimumOsVersionHasForce ?? '',
    });
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // Release: at most hourly (Remote Config throttles more often).
        minimumFetchInterval: kReleaseMode
            ? const Duration(hours: 1)
            : const Duration(minutes: 1),
      ),
    );
    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      // Offline / throttled: last activated values or the env defaults apply.
      'Remote Config fetch failed, using cached/default values: $e'.Log(
        'AppUpdate',
      );
    }
    return remoteConfig;
  }

  @override
  Future<Result<AppUpdateConfigEntity, CcFailure>> getConfig() async {
    try {
      final remoteConfig = await _remoteConfig();
      final minimum = remoteConfig.getString(minimumVersionKey).trim();
      return Success(
        AppUpdateConfigEntity(
          hasForce: remoteConfig.getBool(forceUpdateConfigKey),
          minimumVersion: minimum.isEmpty ? null : minimum,
          iosAppStoreId: _iosAppStoreId,
        ),
      );
    } catch (e) {
      _ready = null; // allow a retry on the next check
      return _envFallback(e);
    }
  }

  /// Remote Config itself unavailable (e.g. plugin error): env values only.
  Result<AppUpdateConfigEntity, CcFailure> _envFallback(Object error) {
    try {
      'Remote Config unavailable, using env values: $error'.Log('AppUpdate');
      final env = HttpClientConfig.httpConfig;
      return Success(
        AppUpdateConfigEntity(
          hasForce: env.hasForceUpdate,
          minimumVersion: env.minimumOsVersionHasForce,
          iosAppStoreId: _iosAppStoreId,
        ),
      );
    } catch (e) {
      return Error(CcUnknownFailure('Failed to read app update config: $e'));
    }
  }
}
