import 'package:flutter/material.dart';

import '../../data/datasource/route_strategy.dart';
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

  @override
  void initState() {
    super.initState();
    _routingStrategy = getIt<RoutingStrategy>();
  }

  @override
  Widget build(BuildContext context) {
    // _routingStrategy.buildApp(): Builds the themed MaterialApp + Router + Localization.
    return _routingStrategy.buildApp();
  }

  @override
  void dispose() {
    // Ensures all lazy singletons and streams in the DI container are disposed.
    getIt.reset();
    super.dispose();
  }
}
