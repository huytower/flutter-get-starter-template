import 'package:flutter/foundation.dart';

import '../../../enum/environment.dart';
import '../env/base.dart';
import '../env/free.dart';
import '../env/prod.dart';
import '../env/uat.dart';

/// Central configuration manager for the application.
/// Handles environment-specific configurations and feature flags.
class HttpClientConfig {
  // Private constructor to prevent instantiation
  HttpClientConfig._();

  static Environment environment = _getEnvironmentFromArgs();

  /// Retrieves the environment from command line arguments or defaults to FREE_FAKE_API.
  static Environment _getEnvironmentFromArgs() {
    try {
      final env = const String.fromEnvironment(
        'ENV',
        defaultValue: 'free',
      ).toLowerCase();

      // Map common aliases to environment values
      final envMap = {
        'free': Environment.FREE_FAKE_API,
        'free_fake_api': Environment.FREE_FAKE_API,
        'uat': Environment.UAT,
        'prod': Environment.PROD,
        'production': Environment.PROD,
      };

      return envMap[env] ?? Environment.FREE_FAKE_API;
    } catch (e) {
      if (kReleaseMode) {
        rethrow;
      }
      return Environment.FREE_FAKE_API;
    }
  }

  /// Get the appropriate HTTP configuration based on the current environment
  static HttpBase get httpConfig {
    switch (environment) {
      case Environment.FREE_FAKE_API:
        return HttpFree();
      case Environment.UAT:
        return HttpUat();
      case Environment.PROD:
        return const HttpProd();
    }
  }

  /// Get the base URL for the current environment
  static String get baseUrl => httpConfig.baseUrl;

  /// Get API headers for the current environment
  static Map<String, String> get apiHeaders => httpConfig.apiHeaders;

  /// Check if the current environment is production
  static bool get isProduction => environment == Environment.PROD;

  /// Check if the current environment is UAT
  static bool get isUat => environment == Environment.UAT;

  /// Check if the current environment is free/fake API
  static bool get isFree => environment == Environment.FREE_FAKE_API;
}
