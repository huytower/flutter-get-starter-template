import 'package:catcher_2/catcher_2.dart';
import 'package:cc_micro_features/features/crash_log/export_crash_log.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';

import '../../../category/export_category.dart';
import '../pages/terms_of_service_page.dart';

/// Screens the profile opens.
abstract final class ProfileRoutes {
  static void categorySettings(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<bool>(builder: (_) => const CategorySettingsPage()));

  static void terms(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const TermsOfServicePage()));

  /// Developer crash-log viewer; no-op unless enabled for this build.
  static void crashLogViewer(BuildContext context) {
    if (!CrashLogDevOverlay.isViewerEnabled) return;
    final navContext = Catcher2.navigatorKey.currentContext ?? context;
    CcDialogHelper.showModalBottomSheet(navContext, const CrashLogViewerPage());
  }
}
