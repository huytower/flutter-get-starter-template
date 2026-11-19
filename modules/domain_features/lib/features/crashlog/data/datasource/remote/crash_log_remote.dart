import 'package:cc_sdk/export_cc_sdk.dart';
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
