import 'package:bridge/navigation_bridge_service.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:domain_features/features/budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import 'package:domain_features/features/budget_limit/presentation/get_x/budget_limit_controller.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/notification/domain/usecases/check_audit_reminder_usecase.dart';
import 'package:domain_features/features/notification/domain/usecases/check_cloud_backup_reminder_usecase.dart';
import 'package:domain_features/features/transaction/presentation/get_x/transaction_controller.dart';
import 'package:domain_features/features/user_level/presentation/get_x/user_level_controller.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
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
        await getIt<FinancialDataSyncService>().pullFromFirestore();
      } catch (e) {
        '❌ getIt<FinancialDataSyncService>() pullFromFirestore() failed | error=$e'
            .Log('NavigationBridgeService');
      }
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
