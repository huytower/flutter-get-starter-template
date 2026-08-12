import 'package:app_config/core/config/http/http_client/http_client_config.dart';
import 'package:app_config/core/enum/environment.dart';
import 'package:app_config/data/datasource/remote/app_version_api.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Logs the current app version and build information
Future<void> logVersionInfo() async {
  try {
    final versionService = AppVersionAPI();
    final version = await versionService.getCurrentVersion();
    final buildNumber = await versionService.getBuildNumber();
    final packageName = await versionService.getPackageName();
    final isPreRelease = await versionService.isPreRelease();

    '📱 App Version Info\n'
        '   • Version: $version\n'
        '   • Build: $buildNumber\n'
        '   • Package: $packageName\n'
        '   • Pre-release: $isPreRelease'
        .Log('AppVersion');
  } catch (e, stackTrace) {
    '❌ Failed to get version info: $e'.Log('AppVersion');
    stackTrace.Log('AppVersion');
  }
}

/// Initializes environment variables without logging
Future<void> initEnv() async {
  final env = HttpClientConfig.environment;
  String envFile;
  switch (env) {
    case Environment.UAT:
      envFile = '.env.uat';
      break;
    case Environment.PROD:
      envFile = '.env.production';
      break;
  }
  await dotenv.load(fileName: 'env/$envFile');
}

Future<void> logEnv() async {
  try {
    // Use the environment defined in HttpClientConfig as the source of truth
    final env = HttpClientConfig.environment;

    if (!dotenv.isInitialized) {
      await initEnv();
    }

    // Log env info
    '✅ Running in ${env.name} environment'.Log('EnvConfig');
    '🌐 API URL: ${dotenv.get('API_URL', fallback: 'Not set')}'.Log('EnvConfig');

    // Log all loaded variables in debug mode
    assert(() {
      final buffer = StringBuffer('📋 Loaded env variables:\n');
      dotenv.env.forEach((key, value) {
        buffer.writeln(
          '   $key: ${key.toLowerCase().contains('key') || key.toLowerCase().contains('secret') ? '***' : value}',
        );
      });
      buffer.toString().Log('EnvConfig');

      return true;
    }());
  } catch (e, stackTrace) {
    '❌ Failed to load env variables: $e'.Log('EnvConfig');
    stackTrace.Log('EnvConfig');
    rethrow;
  }
}
