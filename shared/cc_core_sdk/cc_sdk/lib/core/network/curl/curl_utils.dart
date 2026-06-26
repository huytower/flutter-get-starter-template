import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../export_cc_sdk.dart';

class CurlUtils {
  CurlUtils._internal();

  static final CurlUtils instance = CurlUtils._internal();

  Future<String> representation(RequestOptions options) async {
    List<String> components = [
      'curl --location --request ${options.method} ${options.uri}',
    ];
    options.headers.forEach((k, v) {
      if (k != 'Cookie') {
        components.add('--header "$k: $v"');
      }
    });
    if (options.data != null) {
      final data = jsonEncode(options.data).replaceAll('"', '\\"');
      components.add('--data-raw "$data"');
    }
    var result = components.join(' \\\n\t');
    return result;
  }

  Future<List<T>?> execute<T>(
    String curl, {
    T Function(Map<String, dynamic> json)? converter,
  }) async {
    dynamic _result;
    List<T> _return = [];

    if (curl.contains("curl --location --request") == true) {
      var _split = curl.split("\ --");
      var _request = _split
          .where((element) => element.contains("request"))
          .first;
      var _uri = _request
          .replaceAll("request POST", "")
          .replaceAll("request GET", "")
          .replaceAll(r"'", "")
          .trim();

      var _method = "GET";
      if (_request.contains("POST")) {
        _method = "POST";
      }
      Map<String, dynamic> _headers = <String, dynamic>{};
      _split.toList().where((element) => element.contains("header")).forEach((
        element,
      ) {
        var _element = element.replaceAll("header", "").split(":");
        var _last = _element.last.replaceAll("'", "").trim();
        var _first = _element.first
            .replaceAll(":", "")
            .replaceAll("'", "")
            .trim();
        _headers[_first] = _last;
      });
      _headers.Log("_data :..", true);

      String _data = "";
      var _list = _split
          .toList()
          .where((element) => element.contains("data-raw"))
          .toList();
      if (_list.isNotEmpty) {
        _data = _list.first;
      }
      _data = _data
          .replaceAll("data-raw", "")
          .replaceAll("'{", "{")
          .replaceAll("}'", "}")
          .replaceAll("'''", "'")
          .trim();
      Dio _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 10000),
          headers: _headers,
        ),
      );
      if (_method == "POST") {
        _result = await _dio.post(_uri, data: _data);
      } else {
        _result = await _dio.get(_uri);
      }
      var response = (_result as Response<dynamic>).data;

      ccWhen(
        conditions: {
          response is List: () {
            for (Map<String, dynamic> item in response) {
              _return.add(converter!.call(item));
            }
          },
        },
        orElse: () {
          _return.add(converter!.call(response));
        },
      );
    } else {
      List<String> _split = [];
      curl.split("\' \'").forEach((element) {
        element.split("\ --").forEach((_element) {
          _split.add(_element);
        });
      });
      //_split.Log("_split :...", true);
      var _uri = _split.last.replaceAll("\'", "");
      var _method = "GET";
      if (_split.first.contains("POST")) {
        _method = "POST";
      }
      Map<String, dynamic> _headers = <String, dynamic>{};
      _split
          .toList()
          .where((element) => element.contains("header"))
          .apply((_this) {
            _this.last.contains("' -d '");
          })
          .forEach((element) {
            var _this = element;
            var index = _this.indexOf("' -d '");
            if (_this.contains("' -d '")) {
              _this = _this.substring(0, index);
            }
            var _element = _this.replaceAll("header", "").split(":");
            var _first = _element.first
                .replaceAll("'", "")
                .replaceAll("", "")
                .trim();
            var _last = _element[1].replaceAll("'", "").trim();
            _headers[_first] = _last;
          });

      String _data = "";
      var _list = _split
          .toList()
          .where((element) => element.contains("' -d '"))
          .toList();
      if (_list.isNotEmpty) {
        _data = _list.first.split("' -d '").last;
      }
      _data = _data
          .replaceAll("-d", "")
          .replaceAll("'{", "{")
          .replaceAll("}'", "}")
          .replaceAll("'''", "'")
          .trim();
      Dio _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 10000),
          headers: _headers,
        ),
      );
      String request = "";
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            request = "";
            return handler.next(options);
          },
          onResponse: (response, handler) async {
            var _curl = await CurlUtils.instance.representation(
              response.requestOptions,
            );
            var url =
                "[Dio Interceptor]\n[Request: ${response.requestOptions.method}] : ${response.requestOptions.uri}\n";
            var body = "";
            request = url + body;
            var _message =
                "$request[Curl]:\n$_curl\n[Response: ${response.statusCode}]:\n ${response.data}";
            _message.Log("", true, "logger:###/");
            return handler.next(response);
          },
          onError: (e, handler) {
            return handler.next(e);
          },
        ),
      );

      if (_method == "POST") {
        _result = await _dio.post(_uri, data: _data);
      } else {
        _result = await _dio.get(_uri);
      }
      var response = (_result as Response<dynamic>).data;

      ccWhen(
        conditions: {
          response is List: () {
            for (Map<String, dynamic> item in response) {
              _return.add(converter!.call(item));
            }
          },
        },
        orElse: () {
          _return.add(converter!.call(response));
        },
      );
    }
    return _return;
  }
}
