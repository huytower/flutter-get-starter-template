import 'dart:io' show Platform;

import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:equatable/equatable.dart';

import '../../app/prj_app_config.dart';

/// Base class for application configuration across different environments.
///
/// This abstract class defines the contract that all env-specific
/// configuration classes must implement. It provides default implementations
/// for common configuration values that can be overridden as needed.
///
/// The class is immutable after instantiation to ensure thread safety and
/// prevent accidental modifications at runtime.
///
/// Example usage:
/// ```dart
/// final http = PrjAppConfig.instance;
/// final baseUrl = http.baseUrl;
/// ```
abstract class HttpBase extends Equatable {
  /// Creates a new immutable configuration instance.
  ///
  /// [hasLogger] - Whether general application logging is enabled
  /// [hasEnableLoggerDio] - Whether Dio HTTP client logging is enabled
  const HttpBase({required this.hasLogger, required this.hasEnableLoggerDio});

  /// The current API version.
  ///
  /// This should match the expected API version on the server.
  int get versionApi => 0;

  /// Whether general application logging is enabled
  final bool hasLogger;

  /// Whether Dio HTTP client logging is enabled
  final bool hasEnableLoggerDio;

  /// The base URL for all API requests.
  ///
  /// This should include the protocol (http/https) and domain,
  /// but no trailing slash.
  /// Example: 'https://api.example.com/v1'
  String get baseUrl;

  /// Timeout duration for API requests in seconds.
  ///
  /// Defaults to 30 seconds.
  int get apiTimeoutSeconds => 30;

  /// Maximum number of retry attempts for failed API requests.
  ///
  /// Set to 0 to disable retries.
  int get maxRetries => 2;

  /// Delay between retry attempts in milliseconds.
  ///
  /// This is the initial delay, which may be increased with exponential backoff.
  int get retryDelayMs => 1000;

  // Environment Information

  /// Display name for the environment
  String get environmentName => 'BASE';

  /// Whether the current env is development.
  ///
  /// Should be `true` only in development environments.
  bool get hasEnvDev => false;

  /// Whether the current env is production.
  ///
  /// Should be `true` only in production environments.
  bool get hasEnvPro => false;

  /// Whether the current env is UAT.
  bool get hasEnvUat => false;

  /// Whether the current env is free tier.
  bool get hasEnvFree => false;

  // App update (force update)

  /// Default for the forced app update switch (`IS_FORCE_UPDATE`); the live
  /// value comes from Firebase Remote Config (`isForce`).
  bool get hasForceUpdate => false;

  /// Installed versions below this one must update when [hasForceUpdate] is
  /// on (`MINIMUM_OS_VERSION_HAS_FORCE`), a semver app version such as
  /// `1.2.0`. Default for Remote Config `minimumOsVersionHasForce`;
  /// `null` when unset.
  String? get minimumOsVersionHasForce => null;

  // Immutable configuration - no setters

  @override
  List<Object?> get props => [
    PrjAppConfig.VERSION_IOS,
    PrjAppConfig.VERSION_ANDROID,
    versionApi,
    hasLogger,
    hasEnableLoggerDio,
    baseUrl,
    apiTimeoutSeconds,
    maxRetries,
    retryDelayMs,
    hasEnvDev,
    hasEnvPro,
    hasEnvUat,
    hasEnvFree,
    environmentName,
  ];

  @override
  bool? get stringify => true;

  // Validation

  /// Validates that all required configuration values are present and valid.
  ///
  /// This method should be called during app initialization to catch
  /// configuration issues early.
  ///
  /// Throws [CcAppConfigFailure] if any required configuration is missing or invalid.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   http.validate();
  /// } on CcAppConfigFailure catch (e) {
  ///   // Handle configuration error
  /// }
  /// ```
  void validate() {
    // Validate baseUrl
    if (baseUrl.isEmpty) {
      throw const CcMissingConfigFailure('baseUrl');
    }

    // Validate URL format
    if (!baseUrl.startsWith('http')) {
      throw const CcMissingConfigFailure(
        'baseUrl',
        message: 'Must start with http:// or https://',
      );
    }

    // Validate timeouts
    if (apiTimeoutSeconds <= 0) {
      throw const CcMissingConfigFailure(
        'apiTimeoutSeconds',
        message: 'Must be greater than 0',
      );
    }

    // Additional validations for production
    if (hasEnvPro &&
        baseUrl.startsWith('http://') &&
        !baseUrl.contains('localhost')) {
      throw const CcSecurityConfigFailure(
        'Insecure HTTP protocol detected in production env',
        key: 'baseUrl',
        securityRule: 'insecure_protocol',
      );
    }
  }

  // Headers

  /// Returns the default headers for all API requests.
  ///
  /// These headers will be included with every API request unless overridden.
  ///
  /// Returns [Map<String, String>] of default headers
  Map<String, String> get apiHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-App-Version': versionApi.toString(),
    'X-Platform':
        '${Platform.isAndroid ? 'Android' : 'iOS'}-${Platform.operatingSystemVersion}',
  };
}
