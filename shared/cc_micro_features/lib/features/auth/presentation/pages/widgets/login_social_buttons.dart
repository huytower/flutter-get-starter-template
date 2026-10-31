import 'dart:io';

import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
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
              label: el.tr(CcLocaleKeys.auth_login_google),
              onTap: () {
                context.read<LoginBloc>().add(
                  isLinking
                      ? const LinkWithGoogleStarted()
                      : const LoginWithGoogleStarted(),
                );
              },
            ),

            if (Platform.isIOS) ...[
              const CcSpaceMD(),
              CcSocialLoginBtn(
                type: SocialLoginType.apple,
                label: el.tr(CcLocaleKeys.auth_login_apple),
                onTap: () {
                  context.read<LoginBloc>().add(
                    isLinking
                        ? const LinkWithAppleStarted()
                        : const LinkWithAppleStarted(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
