import 'dart:developer' as developer;

import 'package:cc_sdk/core/config/cc_app_track_info.dart';
import 'package:cc_sdk/core/crash_reporting/cc_crash_log_paths.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/crash_log_repository.dart';
import '../datasource/remote/crash_log_remote.dart';
import '../models/crash_log_upload_body.dart';

@LazySingleton(as: CrashLogRepository)
class CrashLogRepositoryImpl implements CrashLogRepository {
  CrashLogRepositoryImpl(this._remote);

  final CrashLogRemote _remote;

  @override
  Future<bool> uploadPendingOnRestart() async {
    if (!CcCrashLogEnv.isUploadEnabled) return false;

    final file = await CcCrashLogPaths.resolveLogFile();
    if (!file.existsSync() || file.lengthSync() == 0) return false;

    final logs = await file.readAsString();

    try {
      await _remote.upload(
        CrashLogUploadBody(
          appName: CcAppTrackName.appName,
          uploadedAt: DateTime.now().toUtc().toIso8601String(),
          logs: logs,
        ),
      );
      await CcCrashLogPaths.clearLogFile();
      developer.log(
        'Crash log uploaded (${logs.length} chars)',
        name: 'CrashLog',
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Crash log upload failed: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'CrashLog',
      );
      return false;
    }
  }
}
