import 'package:flutter/foundation.dart';

/// Build-time settings of this app that change per environment, read from
/// `--dart-define` values.
///
/// Builds pass them with `--dart-define-from-file=env/prod.json`. In CI that
/// file is generated from the repository's GitHub Variables (non-secret
/// values) and Secrets (secret values), which are the single source of truth;
/// locally it is a git-ignored copy of `env/prod.example.json`.
///
/// Rule: every key read here is listed in `env/prod.example.json`, in the same
/// order, and nothing else is. A key missing from the file falls back to the
/// default below. Values that never change per environment are plain
/// constants in code, not keys.
///
/// This is the only place that reads these keys. The SDK receives its share
/// through `CcSdkConfig` (see `initEnv()` in the app shell).
abstract final class PrjEnv {
  PrjEnv._();

  // App.
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'MyApp',
  );
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.production.com',
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
  static const bool enableCrashLogUpload = bool.fromEnvironment(
    'ENABLE_CRASH_LOG_UPLOAD',
    defaultValue: true,
  );
  // ENABLE_DEV_CRASH_LOG_VIEWER is read by `CrashLogDevOverlay`
  // (cc_micro_features) directly.

  // Navigation.
  static const String autoRouteStart = String.fromEnvironment(
    'AUTO_ROUTE_START',
    defaultValue: 'DASHBOARD',
  );

  // Product.
  static const bool enableVipMode = bool.fromEnvironment('ENABLE_VIP_MODE');

  // Force update defaults (live values come from Firebase Remote Config).
  static const bool hasForceUpdate = bool.fromEnvironment('IS_FORCE_UPDATE');
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
