import 'package:auto_route/auto_route.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
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
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          getIt<AuthCoordinator>().navigateToDashboard(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.of(context).pop(),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
