import 'package:domain_features/features/crashlog/domain/usecases/upload_pending_crash_logs_usecase.dart';

import '../di/di.dart';

/// Uploads pending catcher log file via [modules/data] on cold start.
Future<void> uploadPendingCrashLogsOnStartup() async {
  if (!getIt.isRegistered<UploadPendingCrashLogsUseCase>()) {
    return;
  }
  await getIt<UploadPendingCrashLogsUseCase>()();
}
