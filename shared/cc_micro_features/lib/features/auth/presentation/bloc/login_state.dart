import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

/// The user dismissed the Google/Apple sheet. Not an error: the page only
/// closes the loading sheet, no message is shown.
class LoginCancelled extends LoginState {
  const LoginCancelled();
}

class LoginSuccess extends LoginState {
  final CcUserEntity user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}
