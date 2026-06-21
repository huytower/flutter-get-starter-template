import 'dart:io';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'double_back_to_exit_snackbar.dart';

/// Mixin for implementing "press back twice to exit" functionality.
///
/// This version is compatible with both [StatefulWidget] and [StatelessWidget]
/// (including [CcGetView]) as it manages back press state via a static variable.
///
/// Provides platform-specific back button handling:
/// - Android: Requires two back presses within 1 second to exit
/// - iOS: Respects default swipe gesture (1 swipe to exit)
///
/// Usage in [CcGetView]:
/// ```dart
/// class MyPage extends CcGetView<MyController> with DoubleBackToExitMixin {
///   @override
///   Widget build(BuildContext context) {
///     return PopScope(
///       canPop: canPop,
///       onPopInvokedWithResult: (didPop, result) =>
///           onPopInvokedWithResult(context, didPop, result),
///       child: super.build(context),
///     );
///   }
/// }
/// ```
mixin DoubleBackToExitMixin {
  static DateTime? _lastBackPressedAt;
  static const _doubleBackDuration = Duration(seconds: 1);

  /// Message shown on first back press.
  String get backPressMessage =>
      el.tr(CcLocaleKeys.common_press_back_again_to_exit);

  /// Enable double back behavior on iOS (default: false).
  bool get enableDoubleBackOnIOS => false;

  /// Handle custom navigation before double back logic.
  /// Return true to prevent double back logic, false to proceed.
  bool handleCustomNavigation() => false;

  /// Enable double back to exit behavior.
  bool get shouldEnableDoubleBackToExit => true;

  /// Check if the route can pop.
  bool get canPop {
    return Platform.isIOS && !enableDoubleBackOnIOS;
  }

  /// Handle back press invocation.
  void onPopInvokedWithResult(
    BuildContext context,
    bool didPop,
    Object? result,
  ) {
    if (didPop) return;

    if (Platform.isIOS && !enableDoubleBackOnIOS) return;

    if (handleCustomNavigation()) return;

    if (!shouldEnableDoubleBackToExit) {
      _exitApp();
      return;
    }

    final now = DateTime.now();
    final isFirstPress =
        _lastBackPressedAt == null ||
        now.difference(_lastBackPressedAt!) > _doubleBackDuration;

    if (isFirstPress) {
      _lastBackPressedAt = now;
      showDoubleBackPressSnackBar(context, backPressMessage);
    } else {
      _lastBackPressedAt = null;
      _exitApp();
    }
  }

  void _exitApp() {
    SystemNavigator.pop();

    // On some Android devices/emulators (especially Android 11), SystemNavigator.pop()
    // puts the activity in the background but may not terminate the process correctly,
    // leading to a hang (corrupted state) on the next launch.
    // Force terminate the process after a short delay to ensure a clean state.
    if (Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 500), () {
        exit(0);
      });
    }
  }
}
