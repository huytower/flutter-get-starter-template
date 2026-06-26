import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:equatable/equatable.dart';

abstract class PhoneAuthState extends Equatable {
  const PhoneAuthState();

  @override
  List<Object?> get props => [];
}

class PhoneAuthInitial extends PhoneAuthState {
  const PhoneAuthInitial();
}

class PhoneAuthLoading extends PhoneAuthState {
  const PhoneAuthLoading();
}

class PhoneAuthCodeSent extends PhoneAuthState {
  final String verificationId;
  final int? resendToken;

  const PhoneAuthCodeSent(this.verificationId, this.resendToken);

  @override
  List<Object?> get props => [verificationId, resendToken];
}

class PhoneAuthSuccess extends PhoneAuthState {
  final CcUserEntity user;

  const PhoneAuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class PhoneAuthError extends PhoneAuthState {
  final String message;

  const PhoneAuthError(this.message);

  @override
  List<Object?> get props => [message];
}
