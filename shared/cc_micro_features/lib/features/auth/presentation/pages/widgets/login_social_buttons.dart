import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/login_bloc.dart';
import '../../bloc/login_event.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key, this.isLinking = false});

  final bool isLinking;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isLinking;
    final double opacity = isDisabled ? 0.3 : 1.0;

    return Opacity(
      opacity: opacity,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: Column(
          children: [
            CcSocialLoginBtn(
              type: SocialLoginType.google,
              onTap: () {
                'Google Login button tapped (isLinking: $isLinking)'.Log(
                  'LoginSocialButtons',
                );
                context.read<LoginBloc>().add(
                  isLinking
                      ? const LinkWithGoogleStarted()
                      : const LoginWithGoogleStarted(),
                );
              },
            ),

            const CcSpaceMD(),

            CcSocialLoginBtn(
              type: SocialLoginType.apple,
              onTap: () {
                'Apple Login button tapped (isLinking: $isLinking)'.Log(
                  'LoginSocialButtons',
                );
                context.read<LoginBloc>().add(
                  isLinking
                      ? const LinkWithAppleStarted()
                      : const LoginWithAppleStarted(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
