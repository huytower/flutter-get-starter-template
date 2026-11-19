import 'package:app_config/core/config/app/prj_env.dart';
import 'package:cc_sdk/export_cc_sdk.dart';

/// Hands the build-time settings in [PrjEnv] to the SDK.
///
/// Values are compile-time constants (`--dart-define-from-file`), so this is
/// synchronous and cheap; it stays first in the boot sequence because DI and
/// logging read [CcSdkConfig] as soon as they start.
Future<void> initEnv() async {
  CcSdkConfig.configure(
    const CcSdkConfig(
      appName: PrjEnv.appName,
      enableLogger: PrjEnv.enableLogger,
      enableLoggerDio: PrjEnv.enableLoggerDio,
      enableCrashLogUpload: PrjEnv.enableCrashLogUpload,
      aiModelName: PrjEnv.geminiModelName,
    ),
  );
}
