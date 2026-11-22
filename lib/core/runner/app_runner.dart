import 'dart:async';

import 'package:bridge/export_bridge.dart';
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/datasource/routing_strategy.dart';
import '../di/di.dart';

/// The root widget of the application.
///
/// It manages the application lifecycle, initializes the routing strategy,
/// and provides global cross-cutting wrappers (like Crash Logs).
class AppRunner extends StatefulWidget {
  const AppRunner({super.key});

  @override
  State<AppRunner> createState() => _AppRunnerState();
}

class _AppRunnerState extends State<AppRunner> {
  late final RoutingStrategy _routingStrategy;
  StreamSubscription<String>? _regionalSettingsSubscription;

  @override
  void initState() {
    super.initState();
    _routingStrategy = getIt<RoutingStrategy>();
    _regionalSettingsSubscription = getIt<RegionalSettingsContract>()
        .detectedLanguageCode
        .listen(_applyDetectedLocale);
  }

  Future<void> _applyDetectedLocale(String languageCode) async {
    final targetContext = Get.context;
    if (targetContext == null) return;

    final easyLoc = EasyLocalization.of(targetContext);
    if (easyLoc == null) return;

    if (easyLoc.locale.languageCode == languageCode) {
      return;
    }

    '[AppRunner] 🌐 Applying detected regional language: $languageCode (was ${easyLoc.locale.languageCode})'
        .Log('AppRunner');
    await easyLoc.setLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    // _routingStrategy.buildApp(): Builds the themed MaterialApp + Router + Localization.
    return _routingStrategy.buildApp();
  }

  @override
  void dispose() {
    _regionalSettingsSubscription?.cancel();
    // Ensures all lazy singletons and streams in the DI container are disposed.
    getIt.reset();
    super.dispose();
  }
}
