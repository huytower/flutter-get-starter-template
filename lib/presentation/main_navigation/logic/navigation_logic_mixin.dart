import 'dart:async';

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

  void initNavigationLogic() {
    final startRoute = dotenv.maybeGet(
      'AUTO_ROUTE_START',
      fallback: 'DASHBOARD',
    );
    showQuickTestAsSecondTab = _isQuickTestRoute(startRoute);
    checkSplash();

    unawaited(getIt<AppServicesContract>().refreshUserLevel());

    _initBackgroundServices();
  }

  void _initBackgroundServices() {
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      CcAppCheckHelper.initialize();
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      logEnv();
      logVersionInfo();

      await getIt<AppServicesContract>().initNotifications();
      getIt<AppServicesContract>().startFinancialDataSync();

      final session = getIt<SessionContract>();
      if (session.isAuthenticated) {
        try {
          await getIt<AppServicesContract>().pullFromFirestore();
        } catch (e) {
          'Initial cloud sync failed: $e'.Log('NavigationLogicMixin');
        }
      }

      try {
        await getIt<AppServicesContract>().checkAuditReminders();
        await getIt<AppServicesContract>().checkCloudBackupReminders();
      } catch (e) {
        'Reminder check failed: $e'.Log('NavigationLogicMixin');
      }
    });
  }

  void handleTabRefresh(int index) {
    getIt<AppServicesContract>().refreshUserLevel();

    if (index == 0) {
      getIt<AppServicesContract>().refreshBudgetAllocation();
    }
    if (index == 1) {
      getIt<AppServicesContract>().refreshTransactionWalletTotal();
    }
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
