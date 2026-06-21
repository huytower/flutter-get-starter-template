import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:injectable/injectable.dart';

import '../../core/config/http/http_client/http_client_config.dart';
import '../../domain/entities/app_config_entity.dart';
import '../../domain/repositories/app_config_repository.dart';
import '../datasource/remote/app_version_api.dart';

@LazySingleton(as: AppConfigRepository)
class AppConfigRepositoryImpl implements AppConfigRepository {
  final AppVersionAPI _appVersionAPI;

  AppConfigRepositoryImpl(this._appVersionAPI);

  @override
  Future<AppConfigEntity> getConfig() async {
    final version = await _appVersionAPI.getCurrentVersion();
    final buildNumber = await _appVersionAPI.getBuildNumber();
    final packageName = await _appVersionAPI.getPackageName();
    final httpConfig = HttpClientConfig.httpConfig;

    return AppConfigEntity(
      appName: CcAppTrackName.appName,
      packageName: packageName,
      version: version,
      buildNumber: buildNumber,
      environment: httpConfig.environmentName,
      featureFlags: {
        'enable_logger': CcFeatureFlags.isEnableLogger,
        'enable_logger_dio': CcFeatureFlags.isEnableLoggerDio,
        'analytics_enabled': CcFeatureFlags.isAnalyticsEnabled,
        'crash_reporting_enabled': CcFeatureFlags.isCrashReportingEnabled,
      },
    );
  }

  @override
  Future<AppConfigEntity> refreshConfig() async {
    // In a real implementation, you might fetch updated config from a remote API
    // and cache it locally before returning the new state.
    return getConfig();
  }

  @override
  Future<T> getFeatureFlag<T>(String key, {required T defaultValue}) async {
    // Implementation can be expanded to check a remote config service (Firebase, etc.)
    if (T == bool) {
      if (key == 'ENABLE_LOGGER') return CcFeatureFlags.isEnableLogger as T;
      if (key == 'ENABLE_LOGGER_DIO') {
        return CcFeatureFlags.isEnableLoggerDio as T;
      }
      if (key == 'ENABLE_ANALYTICS' || key == 'ANALYTICS_ENABLED') {
        return CcFeatureFlags.isAnalyticsEnabled as T;
      }
      if (key == 'ENABLE_CRASH_REPORTING' || key == 'CRASH_REPORTING_ENABLED') {
        return CcFeatureFlags.isCrashReportingEnabled as T;
      }
      if (key == 'ENABLE_CERT_PINNING') {
        return CcFeatureFlags.isCertificatePinningEnabled as T;
      }
    }
    return defaultValue;
  }

  @override
  Future<bool> isUpdateRequired(String currentVersion) async {
    // This should ideally compare currentVersion with a min version from BE
    final minVersion = await getMinimumRequiredVersion();
    return _appVersionAPI.isUpdateRequired(minVersion);
  }

  @override
  Future<String> getMinimumRequiredVersion() async {
    // This would typically come from a remote configuration or API
    return '1.0.0';
  }
}
