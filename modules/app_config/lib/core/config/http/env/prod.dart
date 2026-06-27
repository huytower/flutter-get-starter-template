import 'dart:developer' as developer;
import 'dart:io';

import 'package:cc_sdk_data/domain/failures/app_config/cc_app_config_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    final url = dotenv.maybeGet(
      'API_URL',
      fallback: 'https://api.production.com',
    );
    if (url == null || url.isEmpty) {
      throw const CcMissingConfigFailure(
        'API_URL',
        message: 'API base URL is required in production',
      );
    }
    return url;
  }

  @override
  int get versionIOS => _getVersion('IOS_VERSION');

  @override
  int get versionAndroid => _getVersion('ANDROID_VERSION_CODE');

  @override
  int get versionApi => _getVersion('API_VERSION');

  /// Gets a version number from env variables with validation.
  ///
  /// [key] - The env variable key to read
  ///
  /// Returns the parsed version number
  /// Throws [CcMissingConfigFailure] if the version is invalid
  int _getVersion(String key) {
    try {
      final value = dotenv.maybeGet(key, fallback: '1') ?? '1';
      final version = int.tryParse(value);

      if (version == null || version <= 0) {
        throw CcMissingConfigFailure(
          key,
          message: 'Version must be a positive integer',
        );
      }

      return version;
    } catch (e, stackTrace) {
      throw CcMissingConfigFailure(key, message: 'Failed to parse version: $e');
    }
  }

  /// Whether analytics collection is enabled.
  ///
  /// Can be overridden with `ENABLE_ANALYTICS=false` in .env
  bool get enableAnalytics => CcFeatureFlags.isAnalyticsEnabled;

  /// Whether crash reporting is enabled.
  ///
  /// Can be overridden with `ENABLE_CRASH_REPORTING=false` in .env
  bool get enableCrashReporting => CcFeatureFlags.isCrashReportingEnabled;

  /// Whether certificate pinning is enabled for http requests.
  ///
  /// Can be overridden with `ENABLE_CERT_PINNING=false` in .env
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
