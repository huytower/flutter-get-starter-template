import 'package:app_config/data/datasource/local/box/register_hive_adapter.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk/core/crash_reporting/cc_crash_log_paths.dart';
import 'package:content_locale/cc_localization.dart' as localization;
import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cc_sdk/core/crash_reporting/cc_catcher_bootstrap.dart';
import 'core/crash_reporting/crash_log_dev_overlay.dart';
import 'package:cc_sdk/core/crash_reporting/crash_log_startup.dart';
import 'core/di/dependency_register.dart';
import 'core/di/inject/inject.dart';
import 'core/runner/app_runner.dart';
import 'main_logging.dart';

/// NOTICE : there are 3 env. : FREE_FAKE_API (FREE) | UAT | PROD
/// MUST write necessary code in this file
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await logEnv();
  await logVersionInfo();

  await initializeDependencies();
  registerSingletonApp();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await registerHiveAdapter();

  await localization.CcLocalization.initialize();

  await uploadPendingCrashLogsOnStartup();

  final logFile = await CcCrashLogPaths.resolveLogFile();

  final rootWidget = CrashLogDevOverlay(
    child: localization.CcLocalization.wrapWithLocalization(
      child: const AppRunner(),
    ),
  );

  Catcher2(
    rootWidget: rootWidget,
    ensureInitialized: false,
    debugConfig: CcCatcherBootstrap.debugOptions(logFile),
    releaseConfig: CcCatcherBootstrap.releaseOptions(logFile),
    profileConfig: CcCatcherBootstrap.profileOptions(logFile),
  );
}
