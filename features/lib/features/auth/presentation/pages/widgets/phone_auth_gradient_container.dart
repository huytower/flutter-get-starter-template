import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

class PhoneAuthGradientContainer extends StatelessWidget {
  const PhoneAuthGradientContainer({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ccColorScheme.surface,
      body: SafeArea(
        child: CcGradientCardLayout(padding: padding, child: child),
      ),
    );
  }
}
