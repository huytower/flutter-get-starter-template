import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk/core/crash_reporting/cc_crashlytics_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// Custom ConsoleHandler that logs device info as JSON instead of individual lines
class _JsonConsoleHandler extends ConsoleHandler {
  @override
  Future<bool> handle(Report report, BuildContext? context) async {
    // Check if this is a device info report
    if (report.error == null && report.stackTrace == null) {
      // This is likely a device info report, log as JSON
      final deviceInfo = _extractDeviceInfo(report);
      if (deviceInfo.isNotEmpty) {
        print('------- DEVICE INFO (JSON) -------');
        print(const JsonEncoder.withIndent('  ').convert(deviceInfo));
        print('----------------------------------');
        return true;
      }
    }

    // Default handling for other reports
    return await super.handle(report, context);
  }

  Map<String, dynamic> _extractDeviceInfo(Report report) {
    final deviceInfo = <String, dynamic>{};

    // Extract custom parameters which may contain device info
    if (report.customParameters.isNotEmpty) {
      deviceInfo.addAll(report.customParameters);
    }

    // Extract device info from the report
    if (report.deviceParameters.isNotEmpty) {
      deviceInfo.addAll(report.deviceParameters);
    }

    return deviceInfo;
  }
}

/// Builds [Catcher2Options] for debug / release with file + console (debug) handlers.
abstract final class CcCatcherBootstrap {
  CcCatcherBootstrap._();

  static Catcher2Options debugOptions(File logFile) =>
      Catcher2Options(SilentReportMode(), [
        _JsonConsoleHandler(),
        FileHandler(logFile, printLogs: kDebugMode),
        CcCrashlyticsHandler(),
      ]);

  static Catcher2Options releaseOptions(File logFile) => Catcher2Options(
    SilentReportMode(),
    [FileHandler(logFile, printLogs: false), CcCrashlyticsHandler()],
  );

  static Catcher2Options profileOptions(File logFile) =>
      releaseOptions(logFile);
}
