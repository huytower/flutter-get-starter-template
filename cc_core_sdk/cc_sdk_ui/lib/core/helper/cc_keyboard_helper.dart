import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CcKeyboardHelper {
  /// Shows the keyboard by focusing a new FocusNode
  ///
  /// [context] - The BuildContext to use for showing the keyboard
  /// [focusNode] - Optional FocusNode to use. If null, a new one will be created
  static void showKeyboard({BuildContext? context, FocusNode? focusNode}) {
    focusNode ??= FocusNode();
    final currentContext = context ?? Get.context;
    if (currentContext != null) {
      FocusScope.of(currentContext).requestFocus(focusNode);
    }
  }

  /// Logic : hide keyboard in two ways
  static void hideKeyboard({BuildContext? context}) {
    if (context == null) {
      Get.focusScope?.unfocus();
    } else {
      var currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
  }

  /// Wraps a widget with GestureDetector to hide keyboard on tap
  ///
  /// [child] - The widget to wrap
  /// [context] - Optional BuildContext to use for hiding keyboard
  /// [behavior] - HitTestBehavior for the GestureDetector
  static Widget dismissOnTap({
    required Widget child,
    BuildContext? context,
    HitTestBehavior behavior = HitTestBehavior.translucent,
  }) {
    return GestureDetector(
      onTap: () => hideKeyboard(context: context),
      behavior: behavior,
      child: child,
    );
  }
}
