import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:message/export_message.dart';

/// Rejects requests while offline and drops headers marked "empty".
class RequestInterceptor extends Interceptor {
  RequestInterceptor(this._connection);

  final InternetConnection _connection;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    /// Check internet connection
    final hasInternet = await CcNetworkHelper(_connection).hasInternet;
    if (!hasInternet) {
      final errorMsg = el.tr(PrjLocaleKeys.app_error_network);
      errorMsg.Log();
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: errorMsg,
        ),
      );
    }

    /// Handle token logic or specific header cleanup
    ccWhen(
      conditions: {
        options.headers.containsValue("empty"): () {
          options.headers.removeWhere((key, value) => value == "empty");
        },
      },
    );

    return handler.next(options);
  }
}
