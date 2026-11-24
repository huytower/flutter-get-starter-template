import 'dart:io';

import 'package:cc_micro_features/l10n/cc_mf_locale_keys.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/login_bloc.dart';
import '../../bloc/login_event.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key, this.hasLinking = false});

  final bool hasLinking;

  @override
  Widget build(BuildContext context) {
    final bool hasDisabled = hasLinking;
    final double opacity = hasDisabled ? 0.3 : 1.0;

    return Opacity(
      opacity: opacity,
      child: IgnorePointer(
        ignoring: hasDisabled,
        child: Column(
          children: [
            CcSocialLoginButton(
              type: CcSocialLoginType.google,
              label: el.tr(CcMfLocaleKeys.auth_login_google),
              onTap: () {
                context.read<LoginBloc>().add(
                  hasLinking
                      ? const LinkWithGoogleStarted()
                      : const LoginWithGoogleStarted(),
                );
              },
            ),

            if (Platform.isIOS) ...[
              const CcSpaceMD(),
              CcSocialLoginButton(
                type: CcSocialLoginType.apple,
                label: el.tr(CcMfLocaleKeys.auth_login_apple),
                onTap: () {
                  context.read<LoginBloc>().add(
                    hasLinking
                        ? const LinkWithAppleStarted()
                        : const LoginWithAppleStarted(),
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
