import 'dart:developer' as developer;
import 'dart:ui';

import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:app_config/data/datasource/local/box/encryption/hive_encryption_service.dart';
import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';
import 'package:theme/presentation/provider/theme_provider.dart';

import 'core/di/di.dart';
import 'core/di/hive_registrar.dart';
import 'core/logging/init_logger.dart';
import 'core/runner/app_runner.dart';

/// The entry point of the application.
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Environment Loading (Critical & Blocking for DI)
    // We load this first because initializeDependencies() depends on env variables.
    // This is very fast (~50ms) and prevents race conditions in the parallel block.
    await initEnv();

    // 2. TURBO PARALLEL BOOT (Awaited Barrier)
    // We run the most critical systems concurrently to hit the < 2s target.
    await Future.wait([
      Firebase.initializeApp(),
      initializeDependencies(),
      _initHive(),
      CcLocalization.initialize(),
    ]);

    // 3. Setup error handling immediately after core systems are ready
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // 4. PRIORITY BACKGROUND (Non-blocking)
    // Starts the native security handshake without delaying the first frame.
    CcAppCheckHelper.initialize();

    // 5. Restore persisted theme before the first frame so the shell opens
    //    with the user's last preference instead of the system default.
    try {
      final savedDark = CcAppStorage.instance.isDarkMode;
      if (savedDark != null && getIt.isRegistered<ThemeProvider>()) {
        getIt<ThemeProvider>().setThemeMode(
          savedDark ? ThemeMode.dark : ThemeMode.light,
        );
      }
    } catch (_) {}

    // 6. UI Launch
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

/// Initializes Hive and its adapters with encryption for financial data.
Future<void> _initHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();

  // Initialize Hive without global cipher
  // We'll apply encryption per-box when opening financial boxes
  Hive.init(appDocumentDir.path);

  // Register all adapters
  await HiveRegistrar.registerAll();

  // Initialize encryption service for financial boxes
  final encryptionService = HiveEncryptionService(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ),
  );

  // Open non-financial boxes without encryption
  await _openNonFinancialBoxes();

  // Open financial boxes with encryption
  await _openFinancialBoxes(encryptionService);
}

/// Opens non-financial boxes without encryption.
///
/// These boxes contain app settings, device info, and logs that don't require encryption.
/// Opening them early ensures they're available when needed.
Future<void> _openNonFinancialBoxes() async {
  for (final boxName in CcHiveBox.nonFinancialBoxes) {
    try {
      await Hive.openBox(boxName);
    } catch (e) {
      developer.log('Failed to open non-financial box: $boxName', error: e);
      // Continue with other boxes even if one fails
    }
  }
}

/// Opens financial boxes with encryption.
///
/// These boxes contain sensitive financial data (wallets, transactions, budgets, etc.)
/// and must be encrypted to protect user privacy.
Future<void> _openFinancialBoxes(HiveEncryptionService encryptionService) async {
  final cipher = await encryptionService.createCipher();

  for (final boxName in CcHiveBox.financialBoxes) {
    try {
      await Hive.openBox(boxName, encryptionCipher: cipher);
    } catch (e) {
      developer.log('Failed to open financial box: $boxName', error: e);
      // Continue with other boxes even if one fails
    }
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
