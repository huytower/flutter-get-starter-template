import 'package:flutter/material.dart';

import '../../export_cc_sdk_ui.dart';

/// Reusable icon widget with project defaults.
///
/// Encapsulates the common `Icon` + `context.respIconSize` + themed color
/// idiom so features do not duplicate it. Defaults to the semantic
/// [ColorScheme.primary] color and a `24` base size; both are overridable.
///
/// Example:
/// ```dart
/// CcIconToken(
///   Icons.settings,
///   size: 22,
///   color: context.ccColorScheme.primary,
/// );
/// ```
class CcIconToken extends StatelessWidget {
  const CcIconToken(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: context.respIconSize(baseSize: size),
      color: color ?? context.ccColorScheme.primary,
    );
  }
}
