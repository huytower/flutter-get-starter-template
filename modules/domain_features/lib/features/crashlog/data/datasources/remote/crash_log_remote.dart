import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../models/crash_log_upload_body.dart';

/// Posts crash log payloads using the shared [baseDio] instance.
@lazySingleton
class CrashLogRemote {
  CrashLogRemote(@Named('baseDio') this._dio);

  final Dio _dio;

  /// Path appended to the API base URL for crash log uploads.
  static const String apiPath = '/client-logs';

  Future<void> upload(CrashLogUploadBody body) async {
    await _dio.post<void>(apiPath, data: body.toJson());
  }
}
