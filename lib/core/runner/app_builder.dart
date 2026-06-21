import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:features/features/crash_log/export_crash_log.dart';
import 'package:flutter/material.dart';

import 'app_runner.dart';

/// Helper class to assemble the root widget tree.
abstract final class AppBuilder {
  AppBuilder._();

  /// Assembles the application with all necessary global wrappers:
  /// 1. [CcLocalization]: For internationalization.
  /// 2. [AppRunner]: The main application shell/router.
  /// 3. [CrashLogDevOverlay]: Developer debugging tools.
  static Widget buildDefaultApp() {
    return const CrashLogDevOverlay(
      child: CcLocalizationWrapper(child: AppRunner()),
    );
  }
}

/// A simple wrapper for localization to keep the builder clean.
class CcLocalizationWrapper extends StatelessWidget {
  final Widget child;

  const CcLocalizationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CcLocalization.wrapWithLocalization(child: child);
  }
}
