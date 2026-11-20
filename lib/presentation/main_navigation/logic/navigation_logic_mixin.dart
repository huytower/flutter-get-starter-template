import 'dart:async';

import 'package:app_config/core/config/app/prj_env.dart';
import 'package:bridge/export_bridge.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_micro_features/features/app_update/presentation/app_update_prompter.dart';
import 'package:cc_micro_features/features/splash/core/splash_manager.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';

import '../tabs/quick_test_tab_content.dart';

mixin NavigationLogicMixin<T extends StatefulWidget> on State<T> {
  bool showQuickTestAsSecondTab = false;
  bool showSplash = true;

  late final AppLifecycleProvider _appLifecycle;
  late final MainShellProvider _mainShell;

  /// The bridge's view of the tabs: pages, badges and refresh logic.
  @protected
  MainShellProvider get mainShell => _mainShell;

  @override
  void initState() {
    super.initState();
    _appLifecycle = getIt<AppLifecycleProvider>();
    _mainShell = getIt<MainShellProvider>();
    initNavigationLogic();
  }

  void initNavigationLogic() {
    const startRoute = PrjEnv.autoRouteStart;
    showQuickTestAsSecondTab = _isQuickTestRoute(startRoute);
    checkSplash();

    // 1. Critical but non-blocking (User level drives UI availability)
    unawaited(_appLifecycle.initializeUserLevel());

    // 2. Forced update gate: after the first frame, never blocking boot.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(getIt<AppUpdatePrompter>().checkAndPrompt(context));
    });

    // 3. Deferred background systems (Non-critical for first frame)
    _initBackgroundServices();
  }

  void _initBackgroundServices() {
    // Delay non-critical background services to avoid competing with UI/Boot
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // Native security & analytics (activate() no-ops if main already ran it)
      unawaited(getIt<CcAppAttestation>().activate());
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

      // Local notifications & sync
      try {
        await _appLifecycle.initializeDataServices();
      } catch (e) {
        '❌ AppLifecycleProvider.initializeDataServices() failed | error=$e'
            .Log('NavigationLogicMixin');
        rethrow;
      }

      // Conditional sync & reminders
      try {
        await _appLifecycle.syncAuthenticatedData();
      } catch (e) {
        '❌ AppLifecycleProvider.syncAuthenticatedData() failed | error=$e'
            .Log('NavigationLogicMixin');
      }

      try {
        await _appLifecycle.checkReminders();
      } catch (e) {
        '❌ AppLifecycleProvider.checkReminders() failed | error=$e'.Log(
          'NavigationLogicMixin',
        );
      }
    });
  }

  void handleTabRefresh(int index) {
    unawaited(_mainShell.refreshTab(MainTab.fromIndex(index)));
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
