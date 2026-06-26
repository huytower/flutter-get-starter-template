import 'package:injectable/injectable.dart';

import '../repositories/crash_log_repository.dart';

@lazySingleton
class UploadPendingCrashLogsUseCase {
  UploadPendingCrashLogsUseCase(this._repository);

  final CrashLogRepository _repository;

  Future<bool> call() => _repository.uploadPendingOnRestart();
}
