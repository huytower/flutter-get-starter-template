import 'package:flutter/foundation.dart';

import '../../../enum/environment.dart';
import '../env/base.dart';
import '../env/prod.dart';

/// Central configuration manager for the application.
/// Handles environment-specific configurations and feature flags.
class HttpClientConfig {
  // Private constructor to prevent instantiation
  HttpClientConfig._();

  static Environment environment = _getEnvironmentFromArgs();

  /// Retrieves the environment from command line arguments or defaults to PROD.
  static Environment _getEnvironmentFromArgs() {
    try {
      final env = const String.fromEnvironment(
        'ENV',
        defaultValue: 'prod',
      ).toLowerCase();

      // Map common aliases to environment values
      final envMap = {'prod': Environment.PROD, 'production': Environment.PROD};

      return envMap[env] ?? Environment.PROD;
    } catch (e) {
      if (kReleaseMode) {
        rethrow;
      }
      return Environment.PROD;
    }
  }

  /// Get the appropriate HTTP configuration based on the current environment
  static HttpBase get httpConfig {
    switch (environment) {
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
}
