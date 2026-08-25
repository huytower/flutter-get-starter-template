import 'dart:async';
import 'dart:io';

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

    '🚀 NavigationLogicMixin initialized | startRoute=$startRoute | time=${DateTime.now().toIso8601String()} | cwd=${Directory.current.path}'.Log('NavigationLogicMixin');

    // 1. Critical but non-blocking (User level drives UI availability)
    '🔍 getIt<UserLevelController>() resolve | method=refresh() | async=true'.Log('NavigationLogicMixin');
    unawaited(getIt<UserLevelController>().refresh());
    '✅ getIt<UserLevelController>() resolved | method=refresh() fired'.Log('NavigationLogicMixin');

    // 2. Deferred background systems (Non-critical for first frame)
    _initBackgroundServices();
  }

  void _initBackgroundServices() {
    // Delay non-critical background services to avoid competing with UI/Boot
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      '🔧 _initBackgroundServices started'.Log('NavigationLogicMixin');

      // Native security & analytics
      CcAppCheckHelper.initialize();
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      logEnv();
      logVersionInfo();

      // Local notifications & sync
      '🔍 getIt<NotificationService>() resolve | method=init()'.Log('NavigationLogicMixin');
      try {
        await getIt<NotificationService>().init();
        '✅ getIt<NotificationService>() resolved | init() completed'.Log('NavigationLogicMixin');
      } catch (e) {
        '❌ getIt<NotificationService>() failed | error=$e'.Log('NavigationLogicMixin');
        rethrow;
      }

      '🔍 getIt<FinancialDataSyncService>() resolve | method=startWatching()'.Log('NavigationLogicMixin');
      try {
        getIt<FinancialDataSyncService>().startWatching();
        '✅ getIt<FinancialDataSyncService>() resolved | startWatching() completed'.Log('NavigationLogicMixin');
      } catch (e) {
        '❌ getIt<FinancialDataSyncService>() failed | error=$e'.Log('NavigationLogicMixin');
        rethrow;
      }

      // Conditional sync & reminders
      '🔍 getIt<SessionContract>() resolve | read-only'.Log('NavigationLogicMixin');
      try {
        final session = getIt<SessionContract>();
        '✅ getIt<SessionContract>() resolved | isAuthenticated=${session.isAuthenticated}'.Log('NavigationLogicMixin');
        if (session.isAuthenticated) {
          '🔍 getIt<FinancialDataSyncService>() resolve | method=pullFromFirestore() | conditional=true'.Log('NavigationLogicMixin');
          try {
            await getIt<FinancialDataSyncService>().pullFromFirestore();
            '✅ getIt<FinancialDataSyncService>() resolved | pullFromFirestore() completed'.Log('NavigationLogicMixin');
          } catch (e) {
            '❌ getIt<FinancialDataSyncService>() pullFromFirestore() failed | error=$e'.Log('NavigationLogicMixin');
          }
        }
      } catch (e) {
        '❌ getIt<SessionContract>() failed | error=$e'.Log('NavigationLogicMixin');
        rethrow;
      }

      try {
        '🔍 getIt<CheckAuditReminderUseCase>() resolve | method=call()'.Log('NavigationLogicMixin');
        await getIt<CheckAuditReminderUseCase>().call();
        '✅ getIt<CheckAuditReminderUseCase>() resolved | call() completed'.Log('NavigationLogicMixin');

        '🔍 getIt<CheckCloudBackupReminderUseCase>() resolve | method=call()'.Log('NavigationLogicMixin');
        await getIt<CheckCloudBackupReminderUseCase>().call();
        '✅ getIt<CheckCloudBackupReminderUseCase>() resolved | call() completed'.Log('NavigationLogicMixin');
      } catch (e) {
        '❌ getIt<CheckAuditReminderUseCase | CheckCloudBackupReminderUseCase>() failed | error=$e'.Log('NavigationLogicMixin');
      }
    });
  }

  void handleTabRefresh(int index) {
    // Re-fetch user level on every tab entry as it can change via actions
    // on other tabs (e.g. completing a task).
    '🔍 getIt<UserLevelController>() resolve | method=refresh() | trigger=handleTabRefresh($index)'.Log('NavigationLogicMixin');
    getIt<UserLevelController>().refresh();
    '✅ getIt<UserLevelController>() resolved | method=refresh() completed'.Log('NavigationLogicMixin');

    // Refresh tab-specific data
    if (index == 0) {
      // _indexWalletAllocation
      if (Get.isRegistered<BudgetAllocationController>()) {
        '🔍 Get.find<BudgetAllocationController>() resolve | trigger=handleTabRefresh($index)'.Log('NavigationLogicMixin');
        Get.find<BudgetAllocationController>().loadAll();
        '✅ Get.find<BudgetAllocationController>() resolved | loadAll() completed'.Log('NavigationLogicMixin');
      } else {
        '⚠️ BudgetAllocationController not registered | fallback to WalletController/BudgetLimitController'.Log('NavigationLogicMixin');
        if (Get.isRegistered<WalletController>()) {
          '🔍 Get.find<WalletController>() resolve | trigger=handleTabRefresh($index)'.Log('NavigationLogicMixin');
          Get.find<WalletController>().loadWallets();
          '✅ Get.find<WalletController>() resolved | loadWallets() completed'.Log('NavigationLogicMixin');
        }
        if (Get.isRegistered<BudgetLimitController>()) {
          '🔍 Get.find<BudgetLimitController>() resolve | trigger=handleTabRefresh($index)'.Log('NavigationLogicMixin');
          Get.find<BudgetLimitController>().loadBudgets();
          '✅ Get.find<BudgetLimitController>() resolved | loadBudgets() completed'.Log('NavigationLogicMixin');
        }
      }
    }
    if (index == 1 && Get.isRegistered<TransactionController>()) {
      // _indexEntry
      '🔍 Get.find<TransactionController>() resolve | trigger=handleTabRefresh($index)'.Log('NavigationLogicMixin');
      Get.find<TransactionController>().refreshWalletTotal();
      '✅ Get.find<TransactionController>() resolved | refreshWalletTotal() completed'.Log('NavigationLogicMixin');
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
