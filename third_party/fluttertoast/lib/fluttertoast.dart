/// No-op stand-in for `package:fluttertoast` (see pubspec.yaml for why).
///
/// Exposes only the API surface `catcher_2`'s `ToastHandler` compiles against.
/// Every call does nothing: the project never registers a `ToastHandler`.
library;

import 'package:flutter/widgets.dart';

// ignore_for_file: constant_identifier_names
enum Toast { LENGTH_SHORT, LENGTH_LONG }

enum ToastGravity {
  TOP,
  BOTTOM,
  CENTER,
  TOP_LEFT,
  TOP_RIGHT,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
  CENTER_LEFT,
  CENTER_RIGHT,
  SNACKBAR,
  NONE,
}

class Fluttertoast {
  const Fluttertoast._();

  static Future<bool?> showToast({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    Object? webBgColor,
    Object? webPosition,
  }) async =>
      false;

  static Future<bool?> cancel() async => false;
}

class FToast {
  factory FToast() => _instance;

  FToast._();

  static final FToast _instance = FToast._();

  FToast init(BuildContext context) => this;

  void showToast({
    required Widget child,
    PositionedToastBuilder? positionedToastBuilder,
    Duration toastDuration = const Duration(seconds: 2),
    ToastGravity? gravity,
    Duration fadeDuration = const Duration(milliseconds: 350),
    bool ignorePointer = false,
    bool isDismissible = false,
  }) {}

  void removeCustomToast() {}

  void removeQueuedCustomToasts() {}
}

typedef PositionedToastBuilder = Widget Function(
  BuildContext context,
  Widget child,
  ToastGravity? gravity,
);
