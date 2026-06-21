import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import 'login_or_divider.dart';
import 'login_sign_up_link.dart';
import 'login_social_buttons.dart';

class LoginCardContent extends StatelessWidget {
  const LoginCardContent({super.key, required this.onPhoneLogin});

  final VoidCallback onPhoneLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CcSpaceLG(),

        // Speech bubble icon
        const CcSpeechBubbleIcon(),

        const CcSpaceLG(),

        // Title
        CcText(
          el.tr(CcLocaleKeys.auth_login),
          textStyle: context.ccTextTheme.headlineMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const CcSpaceXL(),

        // Social login buttons
        const LoginSocialButtons(),

        const CcSpaceXL(),

        // OR divider
        const LoginOrDivider(),

        const CcSpaceXL(),

        // Login with phone number button
        CcBaseBtn(
          onTap: onPhoneLogin,
          title: el.tr(CcLocaleKeys.auth_login_phone),
          bgColor: [
            context.ccColorScheme.primary,
            context.ccColorScheme.primary,
          ],
          textColor: Colors.white,
        ),

        const CcSpaceLG(),

        // Sign up link
        const LoginSignUpLink(),

        const CcSpaceSM(),
      ],
    );
  }
}
