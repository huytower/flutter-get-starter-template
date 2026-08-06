import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:flutter/material.dart';

void navigateFromSplash(BuildContext context) {
  // Use the AuthCoordinator to handle splash-to-main navigation
  // This allows the orchestrator to decide the initial flow based on auth state
  getIt<AuthCoordinator>().navigateToDashboard(context);
}
