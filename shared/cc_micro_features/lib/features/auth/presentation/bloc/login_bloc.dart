import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_apple_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LoginWithAppleUseCase _loginWithAppleUseCase;

  LoginBloc(
    this._loginUseCase,
    this._loginWithGoogleUseCase,
    this._loginWithAppleUseCase,
  ) : super(const LoginInitial()) {
    on<LoginStarted>(_onLoginStarted);
    on<LoginWithGoogleStarted>(_onLoginWithGoogleStarted);
    on<LoginWithAppleStarted>(_onLoginWithAppleStarted);
  }

  Future<void> _onLoginStarted(
    LoginStarted event,
    Emitter<LoginState> emit,
  ) async {
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(const LoginError('This field is required'));
      return;
    }

    emit(const LoginLoading());

    'Logging in with email: ${event.email}'.Log('LoginBloc');

    final result = await _loginUseCase(event.email, event.password);

    result.when(
      (user) {
        'Login success:\n'
                '   ID: ${user.id}\n'
                '   Email: ${user.email}\n'
                '   Name: ${user.firstName} ${user.lastName}'
            .Log('LoginBloc');
        emit(LoginSuccess(user));
      },
      (failure) {
        'Login failure: ${failure.message}'.Log('LoginBloc');
        emit(LoginError(failure.message));
      },
    );
  }

  Future<void> _onLoginWithGoogleStarted(
    LoginWithGoogleStarted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    'Logging in with Google'.Log('LoginBloc');
    final result = await _loginWithGoogleUseCase();
    result.when(
      (user) {
        'Google Login success:\n'
                '   ID: ${user.id}\n'
                '   Email: ${user.email}\n'
                '   Name: ${user.firstName} ${user.lastName}'
            .Log('LoginBloc');
        emit(LoginSuccess(user));
      },
      (failure) {
        'Google Login failure: ${failure.message}'.Log('LoginBloc');
        emit(LoginError(failure.message));
      },
    );
  }

  Future<void> _onLoginWithAppleStarted(
    LoginWithAppleStarted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    final result = await _loginWithAppleUseCase();
    result.when(
      (user) => emit(LoginSuccess(user)),
      (failure) => emit(LoginError(failure.message)),
    );
  }
}
