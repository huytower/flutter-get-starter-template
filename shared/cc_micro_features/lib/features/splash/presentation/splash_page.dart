import 'package:auto_route/annotations.dart';
import 'package:cc_bridge/export_cc_bridge.dart' show AuthCoordinator;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';

import '../../../core/di/di.dart';
import '../core/splash_config.dart';
import '../core/splash_manager.dart';
import 'splash_init.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Supplied by the host app; null means "no splash animation".
  final SplashConfig? _config = getIt.isRegistered<SplashConfig>()
      ? getIt<SplashConfig>()
      : null;

  @override
  void initState() {
    super.initState();
    // Remove native splash screen
    FlutterNativeSplash.remove();
    _controller = AnimationController(vsync: this);

    if (_config == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) navigateFromSplash(context, getIt<AuthCoordinator>());
      });
      return;
    }

    // Check if splash should be shown (only once per week)
    SplashManager.shouldShowSplash().then((shouldShow) {
      if (!shouldShow && mounted) {
        // Skip splash screen if shown within the last week
        navigateFromSplash(context, getIt<AuthCoordinator>());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    if (config == null) return const Scaffold();

    return Scaffold(
      body: Center(
        child: Lottie.asset(
          config.lottieAsset,
          package: config.lottiePackage,
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            _controller.forward();
            Future.delayed(config.displayDuration, () {
              if (!context.mounted) return;
              navigateFromSplash(context, getIt<AuthCoordinator>());
            });
          },
        ),
      ),
    );
  }
}
