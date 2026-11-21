import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:domain_features/features/crashlog/domain/usecases/upload_pending_crash_logs_usecase.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/guideline/guideline_controller.dart';
import 'package:domain_features/features/notification/domain/usecases/check_audit_reminder_usecase.dart';
import 'package:domain_features/features/notification/domain/usecases/check_cloud_backup_reminder_usecase.dart';
import 'package:domain_features/features/profile/user_level/presentation/get_x/user_level_controller.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../contracts/app_lifecycle_provider.dart';

/// Resolves each dependency when its step runs, not at construction, so the
/// shell can hold this provider from boot without building feature
/// controllers early.
@LazySingleton(as: AppLifecycleProvider)
class AppLifecycleProviderImpl implements AppLifecycleProvider {
  @override
  void registerPresentationBindings() {
    Get.lazyPut(() => getIt<GuidelineController>());
  }

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
  Future<void> uploadPendingCrashLogs() async {
    if (!getIt.isRegistered<UploadPendingCrashLogsUseCase>()) {
      return;
    }
    await getIt<UploadPendingCrashLogsUseCase>()();
  }
}
