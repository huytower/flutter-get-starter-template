import 'package:flutter/material.dart';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'package:cc_micro_features/features/splash/core/splash_manager.dart';
import 'package:domain_features/export_domain_features.dart';

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

    // Trigger deferred telemetry and logging once the UI shell is initialized
    _initAppTelemetry();
  }

  void _initAppTelemetry() {
    // Non-blocking, deferred execution using microtask to allow UI to render first
    Future.microtask(() {
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      logEnv();
      logVersionInfo();
    });
  }

  void handleTabRefresh(int index) {
    // These tabs derive their figures from transactions that may have been
    // added on the entry tab, so re-fetch each time the tab is (re)opened — the
    // GetX controllers are kept alive, so onReady() won't fire again on its own.
    if (index == 0) {
      // _indexWalletAllocation
      if (Get.isRegistered<WalletController>()) {
        Get.find<WalletController>().loadWallets();
      }
      if (Get.isRegistered<BudgetLimitController>()) {
        Get.find<BudgetLimitController>().loadBudgets();
      }
    }
    if (index == 1 && Get.isRegistered<TransactionController>()) {
      // _indexEntry
      Get.find<TransactionController>().refreshWalletTotal();
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
