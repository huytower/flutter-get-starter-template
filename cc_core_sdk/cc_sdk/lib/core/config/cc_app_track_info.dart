import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App identity and crash-log settings from root `env/.env.*` (via [dotenv]).
abstract final class CcAppTrackName {
  CcAppTrackName._();

  static const String _defaultAppName = 'MyApp';

  /// `APP_NAME` from dotenv, then `--dart-define=APP_NAME`, then default.
  static String get appName {
    try {
      return dotenv.maybeGet(
            'APP_NAME',
            fallback: const String.fromEnvironment(
              'APP_NAME',
              defaultValue: _defaultAppName,
            ),
          ) ??
          _defaultAppName;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load APP_NAME from env',
        error: e,
        stackTrace: stackTrace,
        name: 'CcAppTrackName',
      );
      return _defaultAppName;
    }
  }
}

/// Crash log upload flags and paths from root env files.
abstract final class CcCrashLogEnv {
  CcCrashLogEnv._();

  static const String defaultApiPath = '/client-logs';

  static bool get isUploadEnabled {
    final raw = dotenv.maybeGet('ENABLE_CRASH_LOG_UPLOAD', fallback: 'true');
    return raw?.toLowerCase() != 'false';
  }

  /// Relative path appended to [API_URL] (Retrofit/Dio baseUrl).
  static String get apiPath =>
      dotenv.maybeGet('CRASH_LOG_API_PATH', fallback: defaultApiPath) ??
      defaultApiPath;
}
