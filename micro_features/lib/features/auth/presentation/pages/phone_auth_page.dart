import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../bloc/phone_auth_bloc.dart';
import '../bloc/phone_auth_state.dart';
import 'otp_verification_page.dart';
import 'phone_input_page.dart';

@RoutePage()
class PhoneAuthPage extends StatelessWidget {
  const PhoneAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PhoneAuthBloc>(),
      child: BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
        buildWhen: (previous, current) =>
            current is PhoneAuthInitial ||
            current is PhoneAuthCodeSent ||
            current is PhoneAuthLoading ||
            current is PhoneAuthError,
        builder: (context, state) {
          // If code is sent, we show the OTP page.
          // We stay on OTP page even during loading/error of the verification step.
          final bool showOtp =
              state is PhoneAuthCodeSent ||
              (context.read<PhoneAuthBloc>().phoneNumber != null &&
                  state is! PhoneAuthInitial);

          if (showOtp) {
            return const OtpVerificationPage();
          }
          return const PhoneInputPage();
        },
      ),
    );
  }
}
