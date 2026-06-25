import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class RequestInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    /// Check internet connection
    final internetConnection = getIt<InternetConnection>();
    final hasInternet = await CcNetworkHelper(internetConnection).hasInternet;
    if (!hasInternet) {
      final errorMsg = el.tr(CcLocaleKeys.app_error_network);
      errorMsg.Log();
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: errorMsg,
        ),
      );
    }

    'onRequest() : ${options.uri}'.Log();

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
