import 'package:auto_route/auto_route.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
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
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          getIt<AuthCoordinator>().navigateToDashboard(context);
        } else if (state is LoginLoading) {
          CcDialogHelper.showLoadingBottomSheet(context);
        } else {
          // Dismiss the loading bottom sheet if it's on top
          Navigator.of(context, rootNavigator: true).popUntil(
            (route) => route.isFirst || route is! ModalBottomSheetRoute,
          );
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
                maxWidth: CcContextExtension(context).isPortrait
                    ? context.respDim(400)
                    : context.respDim(600),
                child: LoginCardContent(
                  onPhoneLogin: () =>
                      getIt<AuthCoordinator>().navigateToPhoneAuth(context),
                  loginTitle: _isLinking
                      ? el.tr(CcLocaleKeys.auth_link_account)
                      : el.tr(CcLocaleKeys.auth_login),
                  phoneLoginTitle: _isLinking
                      ? el.tr(CcLocaleKeys.auth_link_phone)
                      : el.tr(CcLocaleKeys.auth_login_phone),
                  agreeText: el.tr(CcLocaleKeys.auth_agree_prefix),
                  termsText: el.tr(CcLocaleKeys.auth_terms_and_privacy),
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
