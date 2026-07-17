import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../config/http/http_client/http_client_config.dart';

class LoggerHelper {
  static void printCustom(dynamic str) {
    if (HttpClientConfig.isProduction) {
      return;
    }
    if (str is String) {
      final now = DateTime.now();
      final timestamp = DateFormat(
        CcConstantsDateTime.datetimeFormatPattern2Encode,
      ).format(now);
      if (kDebugMode) {
        "$str $timestamp ${now.millisecond} ${now.microsecond}".Log();
      }
    }
  }
}
