import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:domain_features/features/budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import 'package:domain_features/features/budget_limit/presentation/get_x/budget_limit_controller.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/guideline/guideline_controller.dart';
import 'package:domain_features/features/notification/domain/usecases/check_audit_reminder_usecase.dart';
import 'package:domain_features/features/notification/domain/usecases/check_cloud_backup_reminder_usecase.dart';
import 'package:domain_features/features/notification/notification_service.dart';
import 'package:domain_features/features/transaction/presentation/get_x/transaction_controller.dart';
import 'package:domain_features/features/user_level/presentation/get_x/user_level_controller.dart';
import 'package:domain_features/features/wallet/presentation/get_x/wallet_controller.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasource/app_services_impl.dart';
import 'di.config.dart';
import 'module/di_module_config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
  ignoreUnregisteredTypes: CcDiModuleConfig.ignoreUnregisteredTypes,
  externalPackageModulesBefore: CcDiModuleConfig.externalPackageModulesBefore,
)
Future<void> initializeDependencies() async {
  await getIt.init();

  getIt.registerSingleton<AppServicesContract>(AppServicesContractImpl(
    getIt<UserLevelController>(),
    getIt<FinancialDataSyncService>(),
    getIt<NotificationService>(),
    getIt<CheckAuditReminderUseCase>(),
    getIt<CheckCloudBackupReminderUseCase>(),
    getIt<BudgetAllocationController>(),
    getIt<WalletController>(),
    getIt<BudgetLimitController>(),
    getIt<TransactionController>(),
  ));

  Get.lazyPut(() => getIt<GuidelineController>());
}
