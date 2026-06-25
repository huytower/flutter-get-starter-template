import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
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

/// Domain-specific Phone Auth Event.
/// This is a separate sealed class for domain-specific phone auth events.
sealed class DomainPhoneAuthEvent {
  const DomainPhoneAuthEvent();
}

/// Triggered when verification is automatically completed (e.g., auto-retrieval).
class DomainPhoneVerificationCompleted extends DomainPhoneAuthEvent {
  final CcUserEntity user;

  const DomainPhoneVerificationCompleted(this.user);
}

/// Triggered when an error occurs during verification.
class DomainPhoneVerificationFailed extends DomainPhoneAuthEvent {
  final CcFailure failure;

  const DomainPhoneVerificationFailed(this.failure);
}

/// Triggered when an SMS code has been sent to the phone number.
class DomainPhoneCodeSent extends DomainPhoneAuthEvent {
  final String verificationId;
  final int? resendToken;

  const DomainPhoneCodeSent(this.verificationId, this.resendToken);
}

/// Triggered when the auto-retrieval of the SMS code has timed out.
class DomainPhoneCodeAutoRetrievalTimeout extends DomainPhoneAuthEvent {
  final String verificationId;

  const DomainPhoneCodeAutoRetrievalTimeout(this.verificationId);
}
