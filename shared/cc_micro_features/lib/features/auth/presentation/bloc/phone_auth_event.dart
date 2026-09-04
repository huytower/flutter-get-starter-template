import 'package:cc_bridge/export_cc_bridge.dart';
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

class ClearPhoneAuthError extends PhoneAuthEvent {
  const ClearPhoneAuthError();
}

/// Triggered when verification is automatically completed (e.g., auto-retrieval).
class PhoneVerificationCompleted extends PhoneAuthEvent {
  final CcUserEntity user;

  const PhoneVerificationCompleted(this.user);

  @override
  List<Object?> get props => [user];
}

/// Triggered when an error occurs during verification.
class PhoneVerificationFailed extends PhoneAuthEvent {
  final CcFailure failure;

  const PhoneVerificationFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Triggered when an SMS code has been sent to the phone number.
class PhoneCodeSent extends PhoneAuthEvent {
  final String verificationId;
  final int? resendToken;

  const PhoneCodeSent(this.verificationId, this.resendToken);

  @override
  List<Object?> get props => [verificationId, resendToken];
}

/// Triggered when the auto-retrieval of the SMS code has timed out.
class PhoneCodeAutoRetrievalTimeout extends PhoneAuthEvent {
  final String verificationId;

  const PhoneCodeAutoRetrievalTimeout(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}
