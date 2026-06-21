import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/common/managers/splash_manager.dart';
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

  @override
  void initState() {
    super.initState();
    // Remove native splash screen
    FlutterNativeSplash.remove();
    _controller = AnimationController(vsync: this);

    // Check if splash should be shown (only once per week)
    SplashManager.shouldShowSplash().then((shouldShow) {
      if (!shouldShow && mounted) {
        // Skip splash screen if shown within the last week
        navigateFromSplash(context);
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
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/lottie/splash.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            _controller.forward();
            // Navigate after 500ms from when animation loads
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted) {
                navigateFromSplash(context);
              }
            });
          },
        ),
      ),
    );
  }
}
