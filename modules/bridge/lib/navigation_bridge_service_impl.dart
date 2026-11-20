import 'package:bridge/navigation_bridge_service.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:domain_features/export_domain_features.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NavigationBridgeService)
class NavigationBridgeServiceImpl implements NavigationBridgeService {
  @override
  Future<void> initializeUserLevel() async {
    getIt<UserLevelController>().refresh();
  }

  @override
  Future<void> initializeDataServices() async {
    getIt<FinancialDataSyncService>().startWatching();
  }

  @override
  Future<void> syncAuthenticatedData() async {
    final session = getIt<SessionContract>();

    if (session.isAuthenticated) {
      try {
        await getIt<FinancialDataSyncService>().syncAuthenticatedData();
      } catch (e) {
        'SYNC_TRACE BRIDGE syncAuthenticatedData() THREW error=$e'.Log(
          'SYNC_TRACE',
        );
      }
    } else {
      'SYNC_TRACE BRIDGE pull SKIPPED — session not authenticated'.Log(
        'SYNC_TRACE',
      );
    }
  }

  @override
  Future<void> checkReminders() async {
    await getIt<CheckAuditReminderUseCase>().call();

    await getIt<CheckCloudBackupReminderUseCase>().call();
  }

  @override
  Future<void> refreshTab(int index) async {
    getIt<UserLevelController>().refresh();

    if (index == 0) {
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
      Get.find<TransactionController>().refreshWalletTotal();
    }
  }
}
