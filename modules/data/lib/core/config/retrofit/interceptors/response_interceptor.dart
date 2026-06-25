import 'package:cc_sdk/core/config/cc_feature_flags.dart';
import 'package:cc_sdk/core/error/cc_exceptions.dart';
import 'package:cc_sdk/core/extensions/common/cc_logger_extension.dart';
import 'package:cc_sdk/core/network/curl/curl_utils.dart';
import 'package:dio/dio.dart';

import '../params/cc_rest_api_params.dart';
import '../response/header/res_header_model.dart';

/// Interceptor that standardizes all responses into the project's envelope format.
///
/// It ensures that whether the API is internal (enveloped) or external (raw),
/// the downstream code (Repositories) always receives a consistent "Peeled" payload.
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 1. Logging Logic
    'onResponse() : status = ${response.statusCode}'.Log();

    if (CcFeatureFlags.isEnableLoggerDio) {
      final curl = await CurlUtils.instance.representation(
        response.requestOptions,
      );
      final url =
          "[Dio Interceptor]\n[Request: ${response.requestOptions.method}] : ${response.requestOptions.uri}\n";
      final message =
          "$url[Curl]:\n$curl\n[Response: ${response.statusCode}]:\n";

      message.Log("", true, "logger:###/");
    }

    // 2. Normalization Logic
    var rawData = response.data;
    final statusKey = CcRestApiParams.status.name;
    final dataKey = CcRestApiParams.data.name;
    final messageKey = CcRestApiParams.message.name;
    final totalKey = CcRestApiParams.total.name;

    // Determine if this is a "Foreign" response that needs wrapping
    // We check if it is a Map and if it has a BOOLEAN 'status' key.
    bool isStandardEnvelope =
        rawData is Map<String, dynamic> &&
        rawData.containsKey(statusKey) &&
        rawData[statusKey] is bool;

    if (!isStandardEnvelope) {
      // FORCE into standard envelope format (Normalization)
      rawData = {
        statusKey: true, // Assume success for raw external data
        messageKey: 'Normalized',
        dataKey: rawData,
        totalKey: (rawData is List) ? rawData.length : 1,
      };
    }

    // 3. Peeling Logic (Now guaranteed to have a Map with a status key)
    final header = ResHeaderModel.fromJson(rawData);

    if (header.status) {
      // SUCCESS: Strip the envelope and return the inner data
      response.data = rawData[dataKey];
      return handler.next(response);
    } else {
      // BUSINESS FAILURE: Throw business exception
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: CcServerException(
            message: header.message,
            code: header.code,
            errors: header.errors,
          ),
        ),
      );
    }
  }
}
