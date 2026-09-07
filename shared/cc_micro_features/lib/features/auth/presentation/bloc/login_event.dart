import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginStarted extends LoginEvent {
  final String email;
  final String password;

  const LoginStarted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginWithGoogleStarted extends LoginEvent {
  const LoginWithGoogleStarted();
}

class LinkWithGoogleStarted extends LoginEvent {
  const LinkWithGoogleStarted();
}

class LoginWithAppleStarted extends LoginEvent {
  const LoginWithAppleStarted();
}

class LinkWithAppleStarted extends LoginEvent {
  const LinkWithAppleStarted();
}

class LinkWithPhoneStarted extends LoginEvent {
  const LinkWithPhoneStarted();
}

class LoginWithFacebookStarted extends LoginEvent {
  const LoginWithFacebookStarted();
}
