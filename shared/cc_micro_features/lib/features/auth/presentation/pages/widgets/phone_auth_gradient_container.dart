import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import 'auth_two_column_body.dart';

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
        child: CcGradientCardLayout(
          padding: padding,
          // Wider card when the body is laid out in two columns.
          maxWidth: AuthTwoColumnBody.cardMaxWidth(context),
          child: child,
        ),
      ),
    );
  }
}
