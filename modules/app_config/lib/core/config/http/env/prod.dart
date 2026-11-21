import 'dart:developer' as developer;
import 'dart:io';

import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:flutter/foundation.dart';

import '../../app/prj_env.dart';
import '../../app/prj_feature_flags.dart';
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

  // Fixed per build, not per environment, so constants rather than env keys.
  @override
  int get versionIOS => 1;

  @override
  int get versionAndroid => 1;

  @override
  int get versionApi => 1;

  /// Whether analytics collection is enabled.
  ///
  /// From [PrjFeatureFlags].
  bool get enableAnalytics => PrjFeatureFlags.isAnalyticsEnabled;

  /// Whether crash reporting is enabled.
  ///
  /// From [PrjFeatureFlags].
  bool get enableCrashReporting => PrjFeatureFlags.isCrashReportingEnabled;

  /// Whether certificate pinning is enabled for http requests.
  ///
  /// From [PrjFeatureFlags].
  bool get enableCertificatePinning =>
      PrjFeatureFlags.isCertificatePinningEnabled;

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
