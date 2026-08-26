import 'package:bridge/navigation_bridge_service.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:domain_features/features/budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import 'package:domain_features/features/budget_limit/presentation/get_x/budget_limit_controller.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/notification/domain/usecases/check_audit_reminder_usecase.dart';
import 'package:domain_features/features/notification/domain/usecases/check_cloud_backup_reminder_usecase.dart';
import 'package:domain_features/features/notification/notification_service.dart';
import 'package:domain_features/features/transaction/presentation/get_x/transaction_controller.dart';
import 'package:domain_features/features/user_level/presentation/get_x/user_level_controller.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NavigationBridgeServiceImpl implements NavigationBridgeService {
  @override
  Future<void> initializeUserLevel() async {
    '🔍 getIt<UserLevelController>() resolve | method=refresh() | source=NavigationBridgeService'.Log('NavigationBridgeService');
    getIt<UserLevelController>().refresh();
    '✅ getIt<UserLevelController>() resolved | method=refresh() completed'.Log('NavigationBridgeService');
  }

  @override
  Future<void> initializeDataServices() async {
    '🔍 getIt<NotificationService>() resolve | method=init() | source=NavigationBridgeService'.Log('NavigationBridgeService');
    await getIt<NotificationService>().init();
    '✅ getIt<NotificationService>() resolved | method=init() completed'.Log('NavigationBridgeService');

    '🔍 getIt<FinancialDataSyncService>() resolve | method=startWatching() | source=NavigationBridgeService'.Log('NavigationBridgeService');
    getIt<FinancialDataSyncService>().startWatching();
    '✅ getIt<FinancialDataSyncService>() resolved | method=startWatching() completed'.Log('NavigationBridgeService');
  }

  @override
  Future<void> syncAuthenticatedData() async {
    '🔍 getIt<SessionContract>() resolve | read-only | source=NavigationBridgeService'.Log('NavigationBridgeService');
    final session = getIt<SessionContract>();
    '✅ getIt<SessionContract>() resolved | isAuthenticated=${session.isAuthenticated}'.Log('NavigationBridgeService');

    if (session.isAuthenticated) {
      '🔍 getIt<FinancialDataSyncService>() resolve | method=pullFromFirestore() | conditional=true | source=NavigationBridgeService'.Log('NavigationBridgeService');
      try {
        await getIt<FinancialDataSyncService>().pullFromFirestore();
        '✅ getIt<FinancialDataSyncService>() resolved | pullFromFirestore() completed'.Log('NavigationBridgeService');
      } catch (e) {
        '❌ getIt<FinancialDataSyncService>() pullFromFirestore() failed | error=$e'.Log('NavigationBridgeService');
      }
    }
  }

  @override
  Future<void> checkReminders() async {
    '🔍 getIt<CheckAuditReminderUseCase>() resolve | method=call() | source=NavigationBridgeService'.Log('NavigationBridgeService');
    await getIt<CheckAuditReminderUseCase>().call();
    '✅ getIt<CheckAuditReminderUseCase>() resolved | call() completed'.Log('NavigationBridgeService');

    '🔍 getIt<CheckCloudBackupReminderUseCase>() resolve | method=call() | source=NavigationBridgeService'.Log('NavigationBridgeService');
    await getIt<CheckCloudBackupReminderUseCase>().call();
    '✅ getIt<CheckCloudBackupReminderUseCase>() resolved | call() completed'.Log('NavigationBridgeService');
  }

  @override
  Future<void> refreshTab(int index) async {
    '🔍 getIt<UserLevelController>() resolve | method=refresh() | trigger=refreshTab($index) | source=NavigationBridgeService'.Log('NavigationBridgeService');
    getIt<UserLevelController>().refresh();
    '✅ getIt<UserLevelController>() resolved | method=refresh() completed'.Log('NavigationBridgeService');

    if (index == 0) {
      if (Get.isRegistered<BudgetAllocationController>()) {
        '🔍 Get.find<BudgetAllocationController>() resolve | method=loadAll() | trigger=refreshTab($index) | source=NavigationBridgeService'.Log('NavigationBridgeService');
        Get.find<BudgetAllocationController>().loadAll();
        '✅ Get.find<BudgetAllocationController>() resolved | loadAll() completed'.Log('NavigationBridgeService');
      } else {
        '⚠️ BudgetAllocationController not registered | fallback to WalletController/BudgetLimitController | source=NavigationBridgeService'.Log('NavigationBridgeService');
        if (Get.isRegistered<WalletController>()) {
          '🔍 Get.find<WalletController>() resolve | method=loadWallets() | trigger=refreshTab($index) | source=NavigationBridgeService'.Log('NavigationBridgeService');
          Get.find<WalletController>().loadWallets();
          '✅ Get.find<WalletController>() resolved | loadWallets() completed'.Log('NavigationBridgeService');
        }
        if (Get.isRegistered<BudgetLimitController>()) {
          '🔍 Get.find<BudgetLimitController>() resolve | method=loadBudgets() | trigger=refreshTab($index) | source=NavigationBridgeService'.Log('NavigationBridgeService');
          Get.find<BudgetLimitController>().loadBudgets();
          '✅ Get.find<BudgetLimitController>() resolved | loadBudgets() completed'.Log('NavigationBridgeService');
        }
      }
    }
    if (index == 1 && Get.isRegistered<TransactionController>()) {
      '🔍 Get.find<TransactionController>() resolve | method=refreshWalletTotal() | trigger=refreshTab($index) | source=NavigationBridgeService'.Log('NavigationBridgeService');
      Get.find<TransactionController>().refreshWalletTotal();
      '✅ Get.find<TransactionController>() resolved | refreshWalletTotal() completed'.Log('NavigationBridgeService');
    }
  }
}
