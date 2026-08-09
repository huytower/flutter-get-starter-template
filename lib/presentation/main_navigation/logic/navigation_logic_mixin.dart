import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/splash/core/splash_manager.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

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

    // Cold app boot lands on a tab (usually the Transaction entry tab)
    // without ever going through handleTabRefresh, so UserLevelController
    // would otherwise stay at its LV1 `.initial()` value — e.g. showing only
    // 2 Transaction tabs instead of 4 under "force full access" — until the
    // user manually switches tabs. Kick off a refresh here so the reactive
    // Obx wrapping each page's content picks up the real status as soon as
    // it resolves, with no remount required.
    unawaited(getIt<UserLevelController>().refresh());

    _initAppTelemetry();
    _initCloudSync();
    _initReminders();
  }

  void _initAppTelemetry() {
    Future.microtask(() {
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      logEnv();
      logVersionInfo();
    });
  }

  void _initCloudSync() {
    Future.delayed(const Duration(seconds: 3), () async {
      final session = getIt<SessionContract>();
      if (session.isAuthenticated) {
        try {
          await getIt<FinancialDataSyncService>().pullFromFirestore();
        } catch (e) {
          'Initial cloud sync failed: $e'.Log('NavigationLogicMixin');
        }
      }
    });
  }

  void _initReminders() {
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        await getIt<CheckAuditReminderUseCase>().call();
        await getIt<CheckCloudBackupReminderUseCase>().call();
      } catch (e) {
        'Reminder check failed: $e'.Log('NavigationLogicMixin');
      }
    });
  }

  void handleTabRefresh(int index) {
    // The LV1/LV2/LV3 unlock state can change from an action taken on a
    // different page (e.g. completing a reconciliation), so re-fetch it on
    // every tab entry — UserLevelController is always resolvable via getIt
    // (a true app-wide singleton, unlike the page-scoped GetX controllers
    // below which only exist once their page has been visited).
    getIt<UserLevelController>().refresh();

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
