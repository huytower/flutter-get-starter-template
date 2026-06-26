import 'package:cc_sdk/core/config/cc_app_track_info.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../models/crash_log_upload_body.dart';

/// Posts crash log payloads using the shared [baseDio] instance.
@lazySingleton
class CrashLogRemote {
  CrashLogRemote(@Named('baseDio') this._dio);

  final Dio _dio;

  Future<void> upload(CrashLogUploadBody body) async {
    await _dio.post<void>(CcCrashLogEnv.apiPath, data: body.toJson());
  }
}
