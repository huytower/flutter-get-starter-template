import 'package:data/domain/usecases/upload_pending_crash_logs_usecase.dart';
import 'package:get_it/get_it.dart';

/// Uploads pending catcher log file via [modules/data] on cold start.
Future<void> uploadPendingCrashLogsOnStartup() async {
  final getIt = GetIt.instance;
  if (!getIt.isRegistered<UploadPendingCrashLogsUseCase>()) return;
  await getIt<UploadPendingCrashLogsUseCase>()();
}
