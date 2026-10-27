import 'dart:io';

import 'package:app_config/core/config/http/http_client/http_client_config.dart';
import 'package:app_config/core/enum/environment.dart';

import '../../main.dart' as runner;

/// Environment-specific application runner.
/// Handles environment setup and HTTP configuration.
class EnvironmentRunner {
  /// Runs the application with the specified environment configuration.
  static void run(Environment environment, {bool disableSsl = false}) {
    HttpClientConfig.environment = environment;

    if (disableSsl) {
      _disableSslValidation();
    }

    runner.main();
  }

  /// Disables SSL certificate validation.
  /// WARNING: Only use for testing/development. Never use in production.
  static void _disableSslValidation() {
    HttpOverrides.global = _InsecureHttpOverrides();
  }
}

/// HTTP overrides that accept all certificates.
/// WARNING: Only for testing/development. Never use in production.
class _InsecureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
