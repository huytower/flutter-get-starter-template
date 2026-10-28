import 'dart:developer' as developer;

import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import 'core/crash_reporting/crash_log_startup.dart';
import 'core/di/di.dart';
import 'core/di/hive_registrar.dart';
import 'core/logging/init_logger.dart';
import 'core/runner/app_runner.dart';

/// The entry point of the application.
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 0. Edge-to-Edge and System UI Configuration
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 1. Environment Loading (Critical & Blocking for DI)
    // We load this first because initializeDependencies() depends on env variables.
    // This is very fast (~50ms) and prevents race conditions in the parallel block.
    await initEnv();

    await Future.wait([
      _bootFirebase(),
      _bootDI(),
      _bootHive(),
      _bootLocalization(),
    ]);

    // 3. Setup error handling immediately after core systems are ready
    // Non-critical, non-blocking: upload any pending crash log from a previous session.
    uploadPendingCrashLogsOnStartup();

    // 4. UI Launch
    _runApplication();
  } catch (error, stackTrace) {
    developer.log(
      '❌ FATAL BOOTSTRAP ERROR | error=$error',
      error: error,
      stackTrace: stackTrace,
      name: 'Main',
    );
    '❌ FATAL BOOTSTRAP ERROR | error=$error'.Log('Main');
    stackTrace.Log('Main');
    runApp(ErrorPage(message: error.toString()));
    developer.log('✅ ErrorPage launched', name: 'Main');
    '✅ ErrorPage launched'.Log('Main');
  }
}

/// Configures and launches the application shell.
Future<void> _runApplication() async {
  final logFile = await CcCrashLogPaths.resolveLogFile();
  Catcher2(
    rootWidget: const AppRunner(),
    ensureInitialized: false,
    debugConfig: CcCatcherBootstrap.debugOptions(logFile),
    releaseConfig: CcCatcherBootstrap.releaseOptions(logFile),
    profileConfig: CcCatcherBootstrap.profileOptions(logFile),
  );
}

Future<void> _bootFirebase() async {
  await Firebase.initializeApp();
}

Future<void> _bootDI() async {
  await initializeDependencies();
}

Future<void> _bootHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();

  Hive.init(appDocumentDir.path);

  await HiveRegistrar.registerAll();
}

Future<void> _bootLocalization() async {
  await CcLocalization.initialize();
}
