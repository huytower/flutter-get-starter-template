import 'package:catcher_2/catcher_2.dart';
import 'package:cc_sdk_ui/core/helper/cc_dialog_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'crash_log_viewer_page.dart';

/// Wraps the app root; **long-press** anywhere opens the on-device crash log viewer (dev).
class CrashLogDevOverlay extends StatefulWidget {
  const CrashLogDevOverlay({required this.child, super.key});

  final Widget child;

  static bool get isViewerEnabled {
    if (kDebugMode) {
      return true;
    }
    final flag = dotenv.maybeGet(
      'ENABLE_DEV_CRASH_LOG_VIEWER',
      fallback: 'false',
    );
    return flag?.toLowerCase() == 'true';
  }

  @override
  State<CrashLogDevOverlay> createState() => _CrashLogDevOverlayState();
}

class _CrashLogDevOverlayState extends State<CrashLogDevOverlay> {
  void _openCrashLogViewer() {
    final navContext = Catcher2.navigatorKey.currentContext;
    if (navContext == null) {
      return;
    }
    CcDialogHelper.showModalBottomSheet(navContext, const CrashLogViewerPage());
  }

  @override
  Widget build(BuildContext context) {
    if (!CrashLogDevOverlay.isViewerEnabled) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: _openCrashLogViewer,
      child: widget.child,
    );
  }
}
