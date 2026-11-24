import 'dart:async';

import 'package:bridge/export_bridge.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_catcher/export_cc_sdk_catcher.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:message/export_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:theme/core/helper/theme_helper.dart';

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

    // Orientation: phones portrait-only, tablets/foldables free. Applied
    // before the first frame (fire-and-forget) so a phone held sideways never
    // flashes a landscape UI; OrientationPolicyScope keeps it current after.
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view != null) {
      unawaited(
        CcOrientationPolicy.apply(
          view.physicalSize / view.devicePixelRatio,
        ),
      );
    }

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
    unawaited(getIt<AppLifecycleProvider>().uploadPendingCrashLogs());
    unawaited(getIt<CcAppAttestation>().activate());

    // 4. UI Launch
    _runApplication();
  } catch (error, stackTrace) {
    '❌ FATAL BOOTSTRAP ERROR | error=$error'.Log('Main');
    stackTrace.Log('Main');
    // Bootstrap failed before the app shell (and its MaterialApp) existed, so
    // CcErrorPage needs its own MaterialApp for Directionality/Theme/Overlay.
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: createLightTheme(),
        home: CcErrorPage(message: error.toString()),
      ),
    );
    '✅ CcErrorPage launched'.Log('Main');
  }
}

/// Configures and launches the application shell.
Future<void> _runApplication() async {
  final logFile = await CcCrashLogPaths.resolveLogFile();
  // DI is ready here (boot step 2), so uncaught errors also go to the
  // registered crash reporter: Crashlytics plus the #crash Slack channel, in
  // every build mode (see `Dependencies.provideCrashReporter`).
  final crashReporter = getIt<CcCrashReporter>();
  Catcher2(
    rootWidget: const AppRunner(),
    ensureInitialized: false,
    debugConfig: CcCatcherBootstrap.debugOptions(
      logFile,
      crashReporter: crashReporter,
    ),
    releaseConfig: CcCatcherBootstrap.releaseOptions(
      logFile,
      crashReporter: crashReporter,
    ),
    profileConfig: CcCatcherBootstrap.profileOptions(
      logFile,
      crashReporter: crashReporter,
    ),
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
  await PrjLocalization.initialize();
}
