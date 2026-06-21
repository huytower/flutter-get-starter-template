import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/login_bloc.dart';
import '../../bloc/login_event.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CcSocialLoginBtn(
          type: SocialLoginType.google,
          onTap: () =>
              context.read<LoginBloc>().add(const LoginWithGoogleStarted()),
        ),

        const CcSpaceMD(),

        // Facebook login temporarily hidden
        // CcSocialLoginBtn(
        //   type: SocialLoginType.facebook,
        //   onTap: () => context.read<LoginBloc>().add(
        //     const LoginWithFacebookStarted(),
        //   ),
        // ),
        const CcSpaceMD(),

        CcSocialLoginBtn(
          type: SocialLoginType.apple,
          onTap: () =>
              context.read<LoginBloc>().add(const LoginWithAppleStarted()),
        ),
      ],
    );
  }
}
