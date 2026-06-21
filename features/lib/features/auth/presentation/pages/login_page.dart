import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/navigation/features_router.gr.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_state.dart';
import 'widgets/login_card_content.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.router.replacePath(CcRouteConfig.mainNavigation);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.respPadding(CcPaddingParams.PAGE_LG),
                  vertical: context.respPadding(CcPaddingParams.PAGE_LG),
                ),
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: context.isPortrait
                            ? context.respDim(400)
                            : context.respDim(600),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          context.respDim(CcPaddingParams.DESC_LG),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: context.respDim(20),
                            offset: Offset(0, context.respDim(10)),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(
                        context.respPadding(CcPaddingParams.PAGE_XL),
                      ),
                      child: LoginCardContent(
                        onPhoneLogin: () =>
                            context.router.push(const PhoneAuthRoute()),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
