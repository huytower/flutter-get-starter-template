/// What the host app shows on the splash screen.
///
/// The splash feature is project-blind, so the animation asset belongs to the
/// app: register an implementation in DI (e.g.
/// `@LazySingleton(as: SplashConfig)` in the App Shell). When none is
/// registered, [SplashPage] shows no animation and moves straight on.
abstract class SplashConfig {
  /// Lottie JSON asset path, e.g. `assets/lottie/splash.json`.
  String get lottieAsset;

  /// Package that bundles [lottieAsset]; null when the asset is the app's own.
  String? get lottiePackage => null;

  /// How long the animation stays on screen before navigating on.
  Duration get displayDuration => const Duration(milliseconds: 2000);
}
