import 'dart:developer' as developer;
import 'dart:io';

import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/foundation.dart';

import '../../app/prj_env.dart';
import 'base.dart';

/// Production env configuration.
///
/// This configuration is used when the app is built for production deployment.
/// It enables production-specific settings and optimizations.
///
/// This class is immutable and can only be instantiated once per application
/// lifecycle through the [CcAppConfig] singleton.
///
/// To use this configuration, set the env to `prod`:
/// ```
/// flutter run --dart-define=ENV=prod
/// ```
///
/// Or for release builds:
/// ```
/// flutter build apk --dart-define=ENV=prod
/// ```
class HttpProd extends HttpBase {
  /// Creates a production configuration instance.
  ///
  /// Prefer using [CcAppConfig.instance] to get the current configuration.
  const HttpProd()
    : super(
        isLogger: false, // Disable logging in production by default
        isEnableLoggerDio: false,
      );

  @override
  final String environmentName = 'PRODUCTION';

  @override
  bool get isEnvPro => true; // Mark as production environment

  @override
  String get baseUrl {
    const url = PrjEnv.apiUrl;
    if (url.isEmpty) {
      throw const CcMissingConfigFailure(
        'API_URL',
        message: 'API base URL is required in production',
      );
    }
    return url;
  }

  /// `IS_FORCE_UPDATE` (see [PrjEnv]). Anything but `true` is off.
  @override
  bool get isForceUpdate => PrjEnv.isForceUpdate;

  /// `MINIMUM_OS_VERSION_HAS_FORCE` (see [PrjEnv]). Blank reads as unset.
  @override
  String? get minimumOsVersionHasForce {
    final value = PrjEnv.minimumOsVersionHasForce.trim();
    return value.isEmpty ? null : value;
  }

  @override
  int get versionIOS => _parseVersion('IOS_VERSION', PrjEnv.iosVersion);

  @override
  int get versionAndroid =>
      _parseVersion('ANDROID_VERSION_CODE', PrjEnv.androidVersionCode);

  @override
  int get versionApi => _parseVersion('API_VERSION', PrjEnv.apiVersion);

  /// Parses a version number read from [PrjEnv].
  ///
  /// Throws [CcMissingConfigFailure] naming [key] if [value] is not a
  /// positive integer.
  int _parseVersion(String key, String value) {
    final version = int.tryParse(value.trim());
    if (version == null || version <= 0) {
      throw CcMissingConfigFailure(
        key,
        message: 'Version must be a positive integer, got "$value"',
      );
    }
    return version;
  }

  /// Whether analytics collection is enabled.
  ///
  /// Set with `ENABLE_ANALYTICS` (see [PrjEnv]).
  bool get enableAnalytics => CcFeatureFlags.isAnalyticsEnabled;

  /// Whether crash reporting is enabled.
  ///
  /// Set with `ENABLE_CRASH_REPORTING` (see [PrjEnv]).
  bool get enableCrashReporting => CcFeatureFlags.isCrashReportingEnabled;

  /// Whether certificate pinning is enabled for http requests.
  ///
  /// Set with `ENABLE_CERT_PINNING` (see [PrjEnv]).
  bool get enableCertificatePinning =>
      CcFeatureFlags.isCertificatePinningEnabled;

  @override
  Map<String, String> get apiHeaders => {
    ...super.apiHeaders,
    'X-Environment': environmentName,
    'X-App-Platform': Platform.operatingSystem,
    'X-App-Version': '${Platform.operatingSystem}-${Platform.version}',
    if (enableAnalytics) 'X-Analytics-Enabled': 'true',
    if (enableCrashReporting) 'X-Crash-Reporting': 'true',
  };

  @override
  void validate() {
    super.validate(); // Validates base class constraints

    if (kReleaseMode) {
      // Additional production-specific validations
      if (baseUrl.startsWith('http://') && !baseUrl.contains('localhost')) {
        throw const CcSecurityConfigFailure(
          'Insecure HTTP protocol detected in production environment',
          key: 'baseUrl',
          securityRule: 'insecure_protocol',
          severity: 'critical',
        );
      }

      if (!enableCertificatePinning) {
        developer.log('Certificate pinning is disabled in production');
      }
    }

    if (enableAnalytics && !enableCrashReporting) {
      developer.log('Analytics is enabled but crash reporting is disabled');
    }
  }

  @override
  List<Object?> get props => [
    ...super.props,
    enableAnalytics,
    enableCrashReporting,
    enableCertificatePinning,
  ];
}
