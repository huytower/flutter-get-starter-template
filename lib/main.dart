import 'dart:developer' as developer;
import 'dart:ui';

import 'package:app_config/data/datasource/local/box/register_hive_adapter.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import 'core/di/di.dart';
import 'core/logging/init_logger.dart';
import 'core/runner/app_runner.dart';

/// The entry point of the application.
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

    // Initialize Firebase App Check for device attestation
    await CcAppCheckHelper.initialize();

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await logEnv();
    await logVersionInfo();

    await initializeDependencies();

    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    await registerHiveAdapter();

    await CcLocalization.initialize();

    _runApplication();
  } catch (error, stackTrace) {
    developer.log(
      'FATAL BOOTSTRAP ERROR',
      error: error,
      stackTrace: stackTrace,
    );
    runApp(ErrorPage(message: error.toString()));
  }
}

/// Configures and launches the application shell.
void _runApplication() async {
  final logFile = await CcCrashLogPaths.resolveLogFile();

  Catcher2(
    rootWidget: const AppRunner(),
    ensureInitialized: false,
    debugConfig: CcCatcherBootstrap.debugOptions(logFile),
    releaseConfig: CcCatcherBootstrap.releaseOptions(logFile),
    profileConfig: CcCatcherBootstrap.profileOptions(logFile),
  );
}
