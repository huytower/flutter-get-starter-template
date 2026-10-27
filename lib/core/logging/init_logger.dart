import 'package:app_config/core/config/http/http_client/http_client_config.dart';
import 'package:app_config/core/enum/environment.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Initializes environment variables without logging
Future<void> initEnv() async {
  final env = HttpClientConfig.environment;
  String envFile;
  switch (env) {
    case Environment.PROD:
      envFile = '.env.prod';
      break;
  }
  try {
    await dotenv.load(fileName: 'env/$envFile');
  } catch (e, stackTrace) {
    '❌ Failed to load environment file env/$envFile: $e'.Log('EnvConfig');
    stackTrace.Log('EnvConfig');
    rethrow;
  }
}

Future<void> logEnv() async {
  try {
    if (!dotenv.isInitialized) {
      await initEnv();
    }
  } catch (e, stackTrace) {
    '❌ Failed to load env variables: $e'.Log('EnvConfig');
    stackTrace.Log('EnvConfig');
    rethrow;
  }
}
