import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:flutter/material.dart';

/// Leaves the splash: [auth] (the orchestrator) picks the first screen from
/// the session state.
void navigateFromSplash(BuildContext context, AuthCoordinator auth) {
  auth.navigateToDashboard(context);
}
