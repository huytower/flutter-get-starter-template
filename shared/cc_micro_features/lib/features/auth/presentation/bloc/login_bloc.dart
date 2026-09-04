import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/auth_preference_datasource.dart';
import '../../domain/usecases/link_with_google_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_apple_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LinkWithGoogleUseCase _linkWithGoogleUseCase;
  final LoginWithAppleUseCase _loginWithAppleUseCase;
  final AuthPreferenceDataSource _preferenceDataSource;

  LoginBloc(
    this._loginUseCase,
    this._loginWithGoogleUseCase,
    this._linkWithGoogleUseCase,
    this._loginWithAppleUseCase,
    this._preferenceDataSource,
  ) : super(const LoginInitial()) {
    on<LoginStarted>(_onLoginStarted);
    on<LoginWithGoogleStarted>(_onLoginWithGoogleStarted);
    on<LinkWithGoogleStarted>(_onLinkWithGoogleStarted);
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
      (user) async {
        await _preferenceDataSource.setTermsAccepted(true);
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
    'LoginWithGoogleUseCase result: ${result.isSuccess() ? "Success" : "Failure"}'
        .Log('LoginBloc');
    if (result.isSuccess()) {
      await _preferenceDataSource.setTermsAccepted(true);
    }
    result.when(
      (user) {
        'LoginWithGoogle Success: ${user.id}'.Log('LoginBloc');
        emit(LoginSuccess(user));
      },
      (failure) {
        'LoginWithGoogle Failure: ${failure.message}'.Log('LoginBloc');
        emit(LoginError(failure.message));
      },
    );
  }

  Future<void> _onLinkWithGoogleStarted(
    LinkWithGoogleStarted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    'Linking Google account'.Log('LoginBloc');
    final result = await _linkWithGoogleUseCase();
    'LinkWithGoogleUseCase result: ${result.isSuccess() ? "Success" : "Failure"}'
        .Log('LoginBloc');
    if (result.isSuccess()) {
      await _preferenceDataSource.setTermsAccepted(true);
    }
    result.when(
      (user) {
        'LinkWithGoogle Success: ${user.id}'.Log('LoginBloc');
        emit(LoginSuccess(user));
      },
      (failure) {
        'LinkWithGoogle Failure: ${failure.message}'.Log('LoginBloc');
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
    result.when((user) async {
      await _preferenceDataSource.setTermsAccepted(true);
      emit(LoginSuccess(user));
    }, (failure) => emit(LoginError(failure.message)));
  }
}
