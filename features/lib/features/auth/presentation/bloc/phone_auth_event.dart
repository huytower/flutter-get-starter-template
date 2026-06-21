import 'package:equatable/equatable.dart';

abstract class PhoneAuthEvent extends Equatable {
  const PhoneAuthEvent();

  @override
  List<Object?> get props => [];
}

class VerifyPhoneNumberStarted extends PhoneAuthEvent {
  final String phoneNumber;

  const VerifyPhoneNumberStarted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class SignInWithCodeStarted extends PhoneAuthEvent {
  final String smsCode;

  const SignInWithCodeStarted(this.smsCode);

  @override
  List<Object?> get props => [smsCode];
}

class ResetPhoneAuthStarted extends PhoneAuthEvent {
  const ResetPhoneAuthStarted();
}
