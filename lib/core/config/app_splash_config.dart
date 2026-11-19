import 'package:cc_micro_features/export_micro_features.dart' show SplashConfig;
import 'package:injectable/injectable.dart';

/// This app's splash animation, supplied to the `splash` micro-feature.
@LazySingleton(as: SplashConfig)
class AppSplashConfig extends SplashConfig {
  @override
  String get lottieAsset => 'assets/lottie/splash.json';
}
