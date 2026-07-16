import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:catcher_2/model/platform_type.dart';
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

/// Custom FileHandler wrapper to prevent concurrent access to the same file
/// which causes "StreamSink is bound to a stream" errors in Catcher2.
class _SynchronizedFileHandler extends ReportHandler {
  final FileHandler _inner;
  Future<void>? _currentOperation;

  _SynchronizedFileHandler(File logFile, {bool printLogs = false})
    : _inner = FileHandler(logFile, printLogs: printLogs);

  @override
  Future<bool> handle(Report report, BuildContext? context) async {
    while (_currentOperation != null) {
      await _currentOperation;
    }

    final operation = _inner.handle(report, context);
    _currentOperation = operation;
    try {
      return await operation;
    } finally {
      _currentOperation = null;
    }
  }

  @override
  List<PlatformType> getSupportedPlatforms() => _inner.getSupportedPlatforms();
}

/// Builds [Catcher2Options] for debug / release with file + console (debug) handlers.
abstract final class CcCatcherBootstrap {
  CcCatcherBootstrap._();

  static _SynchronizedFileHandler? _cachedHandler;

  static _SynchronizedFileHandler _getHandler(
    File logFile, {
    bool printLogs = false,
  }) {
    return _cachedHandler ??= _SynchronizedFileHandler(
      logFile,
      printLogs: printLogs,
    );
  }

  static Catcher2Options debugOptions(File logFile) =>
      Catcher2Options(SilentReportMode(), [
        _JsonConsoleHandler(),
        _getHandler(logFile, printLogs: kDebugMode),
        CcCrashlyticsHandler(),
      ]);

  static Catcher2Options releaseOptions(File logFile) => Catcher2Options(
    SilentReportMode(),
    [_getHandler(logFile, printLogs: false), CcCrashlyticsHandler()],
  );

  static Catcher2Options profileOptions(File logFile) =>
      releaseOptions(logFile);
}
