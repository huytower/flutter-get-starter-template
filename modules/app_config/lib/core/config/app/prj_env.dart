import 'package:flutter/foundation.dart';

/// Every build-time setting of this app, read from `--dart-define` values.
///
/// Builds pass them with `--dart-define-from-file=env/prod.json`. In CI that
/// file is generated from the repository's GitHub Variables (non-secret
/// values) and Secrets (secret values), which are the single source of truth;
/// locally it is a git-ignored copy of `env/prod.example.json`. A key missing
/// from the file falls back to the default below.
///
/// This is the only place that reads these keys. The SDK receives its share
/// through `CcSdkConfig` (see `initEnv()` in the app shell).
abstract final class PrjEnv {
  PrjEnv._();

  // App identity and backend.
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'MyApp',
  );
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.production.com',
  );
  static const String iosVersion = String.fromEnvironment(
    'IOS_VERSION',
    defaultValue: '1',
  );
  static const String androidVersionCode = String.fromEnvironment(
    'ANDROID_VERSION_CODE',
    defaultValue: '1',
  );
  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: '1',
  );

  // Diagnostics.
  static const bool enableLogger = bool.fromEnvironment(
    'ENABLE_LOGGER',
    defaultValue: !kReleaseMode,
  );
  static const bool enableLoggerDio = bool.fromEnvironment(
    'ENABLE_LOGGER_DIO',
    defaultValue: !kReleaseMode,
  );
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: true,
  );
  static const bool enableCertificatePinning = bool.fromEnvironment(
    'ENABLE_CERT_PINNING',
    defaultValue: true,
  );
  static const bool enableCrashLogUpload = bool.fromEnvironment(
    'ENABLE_CRASH_LOG_UPLOAD',
    defaultValue: true,
  );
  static const String crashLogApiPath = String.fromEnvironment(
    'CRASH_LOG_API_PATH',
    defaultValue: '/client-logs',
  );

  // Navigation.
  static const String mainNavigationPath = String.fromEnvironment(
    'MAIN_NAVIGATION_PATH',
    defaultValue: '/main_navigation',
  );
  static const String loginPath = String.fromEnvironment(
    'LOGIN_PATH',
    defaultValue: '/login',
  );
  static const String autoRouteStart = String.fromEnvironment(
    'AUTO_ROUTE_START',
    defaultValue: 'DASHBOARD',
  );

  // Product.
  static const bool enableVipMode = bool.fromEnvironment('ENABLE_VIP_MODE');

  // Force update defaults (live values come from Firebase Remote Config).
  static const bool isForceUpdate = bool.fromEnvironment('IS_FORCE_UPDATE');
  static const String minimumOsVersionHasForce = String.fromEnvironment(
    'MINIMUM_OS_VERSION_HAS_FORCE',
  );

  // Integrations (secrets in CI).
  static const String slackCrashWebhookUrl = String.fromEnvironment(
    'SLACK_CRASH_WEBHOOK_URL',
  );
  static const String slackFeedbackWebhookUrl = String.fromEnvironment(
    'SLACK_FEEDBACK_WEBHOOK_URL',
  );
  static const String geminiModelName = String.fromEnvironment(
    'GEMINI_MODEL_NAME',
  );
}
