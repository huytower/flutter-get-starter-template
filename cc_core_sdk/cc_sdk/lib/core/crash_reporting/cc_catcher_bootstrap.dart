import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/foundation.dart';

/// Builds [Catcher2Options] for debug / release with file + console (debug) handlers.
abstract final class CcCatcherBootstrap {
  CcCatcherBootstrap._();

  static Catcher2Options debugOptions(File logFile) => Catcher2Options(
    SilentReportMode(),
    [ConsoleHandler(), FileHandler(logFile, printLogs: kDebugMode)],
  );

  static Catcher2Options releaseOptions(File logFile) => Catcher2Options(
    SilentReportMode(),
    [FileHandler(logFile, printLogs: false)],
  );

  static Catcher2Options profileOptions(File logFile) =>
      releaseOptions(logFile);
}
