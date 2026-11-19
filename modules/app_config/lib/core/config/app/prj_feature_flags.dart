import 'prj_env.dart';

/// Product feature flags owned by this app (not by the SDK).
///
/// Generic flags (logger, analytics, crash reporting, certificate pinning)
/// stay in `CcFeatureFlags`; anything tied to this product's business
/// model lives here.
///
/// ```dart
/// if (PrjFeatureFlags.isVipModeEnabled) { ... }
/// ```
abstract final class PrjFeatureFlags {
  PrjFeatureFlags._();

  /// Whether VIP mode is on by default (`ENABLE_VIP_MODE`, default `false`).
  static bool get isVipModeEnabled => PrjEnv.enableVipMode;
}
