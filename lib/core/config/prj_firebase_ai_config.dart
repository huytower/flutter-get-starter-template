import 'package:app_config/core/config/app/prj_env.dart';
import 'package:cc_sdk_firebase/export_cc_sdk_firebase.dart';
import 'package:injectable/injectable.dart';

/// Hands this app's Gemini model id (`GEMINI_MODEL_NAME`) to the SDK's
/// Firebase AI client.
@LazySingleton(as: CcFirebaseAiConfig)
class PrjFirebaseAiConfig implements CcFirebaseAiConfig {
  @override
  String get modelName => PrjEnv.geminiModelName;
}
