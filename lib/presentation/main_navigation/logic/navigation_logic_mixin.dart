import 'dart:async';

import 'package:bridge/navigation_bridge_service.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_micro_features/features/splash/core/splash_manager.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/logging/init_logger.dart';
import '../tabs/quick_test_tab_content.dart';

mixin NavigationLogicMixin<T extends StatefulWidget> on State<T> {
  bool showQuickTestAsSecondTab = false;
  bool showSplash = true;

  late final NavigationBridgeService _navigationBridge;

  @override
  void initState() {
    super.initState();
    _navigationBridge = getIt<NavigationBridgeService>();
    initNavigationLogic();
  }

  void initNavigationLogic() {
    final startRoute = dotenv.maybeGet(
      'AUTO_ROUTE_START',
      fallback: 'DASHBOARD',
    );
    showQuickTestAsSecondTab = _isQuickTestRoute(startRoute);
    checkSplash();

    // 1. Critical but non-blocking (User level drives UI availability)
    unawaited(_navigationBridge.initializeUserLevel());

    // 2. Deferred background systems (Non-critical for first frame)
    _initBackgroundServices();
  }

  void _initBackgroundServices() {
    // Delay non-critical background services to avoid competing with UI/Boot
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // Native security & analytics
      CcAppCheckHelper.initialize();
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      logEnv();
      logVersionInfo();

      // Local notifications & sync
      try {
        await _navigationBridge.initializeDataServices();
      } catch (e) {
        '❌ NavigationBridgeService.initializeDataServices() failed | error=$e'
            .Log('NavigationLogicMixin');
        rethrow;
      }

      // Conditional sync & reminders
      try {
        await _navigationBridge.syncAuthenticatedData();
      } catch (e) {
        '❌ NavigationBridgeService.syncAuthenticatedData() failed | error=$e'
            .Log('NavigationLogicMixin');
      }

      try {
        await _navigationBridge.checkReminders();
      } catch (e) {
        '❌ NavigationBridgeService.checkReminders() failed | error=$e'.Log(
          'NavigationLogicMixin',
        );
      }
    });
  }

  void handleTabRefresh(int index) {
    unawaited(_navigationBridge.refreshTab(index));
  }

  Future<void> checkSplash() async {
    final shouldShow = await SplashManager.shouldShowSplash();
    if (!mounted) return;

    if (shouldShow) {
      setState(() => showSplash = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => showSplash = false);
        }
      });
    } else {
      setState(() => showSplash = false);
    }
  }

  bool _isQuickTestRoute(String? route) {
    return route?.toUpperCase() == QuickTestTabContent.routeName;
  }
}
