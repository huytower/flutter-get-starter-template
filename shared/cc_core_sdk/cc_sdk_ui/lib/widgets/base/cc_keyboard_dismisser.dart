import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

/// A wrapper widget that dismisses the keyboard when the user taps outside of a focused input.
class CcKeyboardDismisser extends StatelessWidget {
  final Widget child;
  final List<GestureType> gestures;

  const CcKeyboardDismisser({
    super.key,
    required this.child,
    this.gestures = const [GestureType.onTap],
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(gestures: gestures, child: child);
  }
}
