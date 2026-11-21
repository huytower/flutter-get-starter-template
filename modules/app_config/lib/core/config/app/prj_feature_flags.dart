import 'prj_env.dart';

/// Feature flags owned by this app.
///
/// The SDK keeps no product flags: only the logger switch lives in
/// `CcSdkConfig`. Everything the app decides (business features, which
/// headers it sends, certificate pinning) lives here.
///
/// ```dart
/// if (PrjFeatureFlags.isVipModeEnabled) { ... }
/// ```
abstract final class PrjFeatureFlags {
  PrjFeatureFlags._();

  /// Whether VIP mode is on by default (`ENABLE_VIP_MODE`, default `false`).
  static bool get isVipModeEnabled => PrjEnv.enableVipMode;

  /// Whether analytics collection is announced to the API (always on).
  static const bool isAnalyticsEnabled = true;

  /// Whether crash reporting is announced to the API (always on).
  static const bool isCrashReportingEnabled = true;

  /// Whether HTTP requests pin the server certificate (always on).
  static const bool isCertificatePinningEnabled = true;
}
