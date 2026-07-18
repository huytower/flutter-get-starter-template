import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

/// Reusable form label component.
/// State-management agnostic widget - can be used with any state management approach.
class CcFormLabel extends StatelessWidget {
  final String text;

  const CcFormLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return CcText(
      text,
      textStyle: context.ccTextTheme.labelMedium?.copyWith(
        color: context.ccColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold
      ),
    );
  }
}
