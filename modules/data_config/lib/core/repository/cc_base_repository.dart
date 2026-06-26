import 'package:cc_sdk/core/error/cc_exceptions.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:dio/dio.dart';
import 'package:multiple_result/multiple_result.dart';

/// Mixin for repositories to handle common logic like error mapping.
///
/// Using a mixin allows repository implementations to share this logic
/// without using up their single inheritance slot.
mixin CcBaseRepository {
  /// Executes a network request and maps any DioException to a Failure.
  Future<Result<T, CcFailure>> safeRequest<T>(
    Future<T> Function() request,
  ) async {
    try {
      final response = await request();
      return Success(response);
    } on CcServerException catch (e) {
      // Handle business failure thrown from the interceptor
      return Error(
        ServerFailure(e.message, statusCode: int.tryParse(e.code ?? '')),
      );
    } on DioException catch (e) {
      // Check if it's a CcServerException wrapped inside DioException
      if (e.error is CcServerException) {
        final serverEx = e.error as CcServerException;
        return Error(
          ServerFailure(
            serverEx.message,
            statusCode: int.tryParse(serverEx.code ?? ''),
          ),
        );
      }
      return Error(mapDioErrorToFailure(e));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
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
      return NetworkFailure(message);
    }

    if (error.response != null) {
      return ServerFailure('Server error: $message', statusCode: statusCode);
    }

    return ServerFailure(message);
  }
}
