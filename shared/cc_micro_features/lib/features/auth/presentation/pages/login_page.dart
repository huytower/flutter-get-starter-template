import 'package:auto_route/auto_route.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_state.dart';
import 'widgets/login_card_content.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.showGradient = true});

  final bool showGradient;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: LoginView(showGradient: showGradient),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key, this.showGradient = true});

  final bool showGradient;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool get _isLinking => FirebaseAuth.instance.currentUser != null;

  @override
  Widget build(BuildContext context) {
    final isVietnamese = context.locale.languageCode == 'vi';

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          getIt<AuthCoordinator>().navigateToDashboard(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildDomainGradientAppBar(
          context,
          title: const SizedBox.shrink(),
          leading: CcIconButton.bouncing(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: context.ccColorScheme.onPrimary,
              size: context.respIconSize(baseSize: 24),
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return CcGradientCardLayout(
                maxWidth: context.isPortrait
                    ? context.respDim(400)
                    : context.respDim(600),
                child: LoginCardContent(
                  onPhoneLogin: () =>
                      getIt<AuthCoordinator>().navigateToPhoneAuth(context),
                  loginTitle: isVietnamese
                      ? (_isLinking ? 'Liên kết tài khoản' : 'Đăng nhập')
                      : (_isLinking ? 'Link Account' : 'Login'),
                  phoneLoginTitle: isVietnamese
                      ? (_isLinking
                          ? 'Liên kết số điện thoại'
                          : 'Đăng nhập bằng số điện thoại')
                      : (_isLinking
                          ? 'Link Phone Number'
                          : 'Login with Phone Number'),
                  agreeText: isVietnamese ? 'Tôi đồng ý với ' : 'I agree with ',
                  termsText: isVietnamese
                      ? 'Điều khoản dịch vụ'
                      : 'Term of Services',
                  isLinking: _isLinking,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
