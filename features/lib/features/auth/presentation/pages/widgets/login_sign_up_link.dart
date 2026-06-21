import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

class LoginSignUpLink extends StatelessWidget {
  const LoginSignUpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CcText(
          el.tr(CcLocaleKeys.auth_no_account),
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        ),
        InkWell(
          onTap: () {},
          child: CcText(
            el.tr(CcLocaleKeys.auth_signup),
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
