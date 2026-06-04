import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CcKeyboardUtils {
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
}
