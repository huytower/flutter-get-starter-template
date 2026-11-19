import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  static bool get isVipModeEnabled => _getBool('ENABLE_VIP_MODE', false);

  static bool _getBool(String key, bool defaultValue) {
    try {
      final value = dotenv.maybeGet(key);
      if (value == null) return defaultValue;
      return value.toLowerCase() == 'true';
    } catch (e) {
      'Failed to parse boolean feature flag for $key: $e'.Log(
        'PrjFeatureFlags',
      );
      return defaultValue;
    }
  }
}
