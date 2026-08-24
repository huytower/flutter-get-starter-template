import 'dart:async';

import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_micro_features/features/splash/core/splash_manager.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:domain_features/features/budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
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

    // 1. Critical but non-blocking (User level drives UI availability)
    unawaited(getIt<UserLevelController>().refresh());

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
      await getIt<NotificationService>().init();
      getIt<FinancialDataSyncService>().startWatching();

      // Conditional sync & reminders
      final session = getIt<SessionContract>();
      if (session.isAuthenticated) {
        try {
          await getIt<FinancialDataSyncService>().pullFromFirestore();
        } catch (e) {
          'Initial cloud sync failed: $e'.Log('NavigationLogicMixin');
        }
      }

      try {
        await getIt<CheckAuditReminderUseCase>().call();
        await getIt<CheckCloudBackupReminderUseCase>().call();
      } catch (e) {
        'Reminder check failed: $e'.Log('NavigationLogicMixin');
      }
    });
  }

  void handleTabRefresh(int index) {
    // Re-fetch user level on every tab entry as it can change via actions
    // on other tabs (e.g. completing a task).
    getIt<UserLevelController>().refresh();

    // Refresh tab-specific data
    if (index == 0) {
      // _indexWalletAllocation
      if (Get.isRegistered<BudgetAllocationController>()) {
        Get.find<BudgetAllocationController>().loadAll();
      } else {
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().loadWallets();
        }
        if (Get.isRegistered<BudgetLimitController>()) {
          Get.find<BudgetLimitController>().loadBudgets();
        }
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
