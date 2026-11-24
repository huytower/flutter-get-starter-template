import 'dart:async';

import 'package:cc_sdk/export_cc_sdk.dart'
    show CcCrashReporter, CcLoggerExtension, CcServerException;
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:dio/dio.dart';
import 'package:multiple_result/multiple_result.dart';

/// Mixin for repositories to handle common logic like error mapping.
///
/// Using a mixin allows repository implementations to share this logic
/// without using up their single inheritance slot.
mixin PrjBaseRepository {
  /// Receives every unexpected exception [safeRequest] turns into a failure.
  /// The host repository gets it through its constructor (the mixin holds no
  /// dependency of its own).
  CcCrashReporter get crashReporter;

  /// Executes a network request and maps any DioException to a Failure.
  ///
  /// Server and network failures are expected and only mapped. Any other
  /// exception is a bug (a missing record, a bad cast, a Hive error): it is
  /// also logged and sent to [crashReporter] before being mapped.
  Future<Result<T, CcFailure>> safeRequest<T>(
    Future<T> Function() request,
  ) async {
    try {
      final response = await request();
      return Success(response);
    } on CcServerException catch (e) {
      // Handle business failure thrown from the interceptor
      return Error(
        CcServerFailure(e.message, statusCode: int.tryParse(e.code ?? '')),
      );
    } on DioException catch (e) {
      // Check if it's a CcServerException wrapped inside DioException
      if (e.error is CcServerException) {
        final serverEx = e.error as CcServerException;
        return Error(
          CcServerFailure(
            serverEx.message,
            statusCode: int.tryParse(serverEx.code ?? ''),
          ),
        );
      }
      return Error(mapDioErrorToFailure(e));
    } catch (e, stackTrace) {
      final reason = '$runtimeType.safeRequest';
      '❌ $reason | $e'.Log(runtimeType.toString());
      // Not awaited: reporting must not delay the failure reaching the UI.
      unawaited(crashReporter.recordError(e, stackTrace, reason: reason));
      return Error(CcServerFailure(e.toString()));
    }
  }

  /// Maps DioException to standardized Failure types.
  CcFailure mapDioErrorToFailure(DioException error) {
    final message = error.message ?? 'Unknown error occurred';
    final statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return CcNetworkFailure(message);
    }

    if (error.response != null) {
      return CcServerFailure('Server error: $message', statusCode: statusCode);
    }

    return CcServerFailure(message);
  }
}
