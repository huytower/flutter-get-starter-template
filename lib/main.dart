import 'dart:developer' as developer;
import 'dart:ui';

import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import 'core/di/di.dart';
import 'core/di/hive_registrar.dart';
import 'core/logging/init_logger.dart';
import 'core/runner/app_runner.dart';

/// The entry point of the application.
void main() async {
  developer.log('🚀 main() entry point | time=${DateTime.now().toIso8601String()}', name: 'Main');
  '🚀 main() entry point | time=${DateTime.now().toIso8601String()}'.Log('Main');
  try {
    developer.log('✅ main() try block entered', name: 'Main');
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('✅ WidgetsFlutterBinding.ensureInitialized() done', name: 'Main');

    // 1. Environment Loading (Critical & Blocking for DI)
    // We load this first because initializeDependencies() depends on env variables.
    // This is very fast (~50ms) and prevents race conditions in the parallel block.
    developer.log('⏳ initEnv() start', name: 'Main');
    await initEnv();
    developer.log('✅ initEnv() done', name: 'Main');

    // Safe to use .Log() now that DotEnv is initialized
    '✅ initEnv() done | DotEnv ready'.Log('Main');

    // 2. TURBO PARALLEL BOOT (Awaited Barrier)
    developer.log('⏳ Parallel boot start | Firebase, DI, Hive, Localization', name: 'Main');
    '⏳ Parallel boot start | Firebase, DI, Hive, Localization'.Log('Main');
    await Future.wait([
      _bootFirebase(),
      _bootDI(),
      _bootHive(),
      _bootLocalization(),
    ]);
    developer.log('✅ Parallel boot done', name: 'Main');
    '✅ Parallel boot done'.Log('Main');

    // 3. Setup error handling immediately after core systems are ready
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    developer.log('✅ Error handlers configured', name: 'Main');
    '✅ Error handlers configured'.Log('Main');

    // 4. UI Launch
    developer.log('🔝 main.dart before _runApplication() | time=${DateTime.now().toIso8601String()}', name: 'Main');
    '🔝 main.dart before _runApplication() | time=${DateTime.now().toIso8601String()}'.Log('Main');
    _runApplication();
    developer.log('🔝 main.dart after _runApplication() | time=${DateTime.now().toIso8601String()}', name: 'Main');
    '🔝 main.dart after _runApplication() | time=${DateTime.now().toIso8601String()}'.Log('Main');
  } catch (error, stackTrace) {
    developer.log('❌ FATAL BOOTSTRAP ERROR | error=$error', error: error, stackTrace: stackTrace, name: 'Main');
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
  developer.log('🚀 _runApplication starting | Catcher2 launch | time=${DateTime.now().toIso8601String()}', name: 'Main');
  '🚀 _runApplication starting | Catcher2 launch | time=${DateTime.now().toIso8601String()}'.Log('Main');
  Catcher2(
    rootWidget: const AppRunner(),
    ensureInitialized: false,
    debugConfig: CcCatcherBootstrap.debugOptions(logFile),
    releaseConfig: CcCatcherBootstrap.releaseOptions(logFile),
    profileConfig: CcCatcherBootstrap.profileOptions(logFile),
  );
  developer.log('✅ _runApplication completed | Catcher2 constructor returned', name: 'Main');
  '✅ _runApplication completed | Catcher2 constructor returned'.Log('Main');
}

Future<void> _bootFirebase() async {
  developer.log('⏳ Firebase.initializeApp() start', name: 'Main');
  '⏳ Firebase.initializeApp() start'.Log('Main');
  await Firebase.initializeApp();
  developer.log('✅ Firebase.initializeApp() done', name: 'Main');
  '✅ Firebase.initializeApp() done'.Log('Main');
}

Future<void> _bootDI() async {
  developer.log('⏳ initializeDependencies() start', name: 'Main');
  '⏳ initializeDependencies() start'.Log('Main');
  await initializeDependencies();
  developer.log('✅ initializeDependencies() done', name: 'Main');
  '✅ initializeDependencies() done'.Log('Main');
}

Future<void> _bootHive() async {
  developer.log('⏳ _initHive() start', name: 'Main');
  '⏳ _initHive() start'.Log('Main');
  final appDocumentDir = await getApplicationDocumentsDirectory();
  developer.log('✅ getApplicationDocumentsDirectory() done | path=${appDocumentDir.path}', name: 'Main');
  '✅ getApplicationDocumentsDirectory() done | path=${appDocumentDir.path}'.Log('Main');

  Hive.init(appDocumentDir.path);
  developer.log('✅ Hive.init() done', name: 'Main');
  '✅ Hive.init() done'.Log('Main');

  await HiveRegistrar.registerAll();
  developer.log('✅ HiveRegistrar.registerAll() done', name: 'Main');
  '✅ HiveRegistrar.registerAll() done'.Log('Main');
}

Future<void> _bootLocalization() async {
  developer.log('⏳ CcLocalization.initialize() start', name: 'Main');
  '⏳ CcLocalization.initialize() start'.Log('Main');
  await CcLocalization.initialize();
  developer.log('✅ CcLocalization.initialize() done', name: 'Main');
  '✅ CcLocalization.initialize() done'.Log('Main');
}
