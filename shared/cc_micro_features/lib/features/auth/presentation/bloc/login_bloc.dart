import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../data/datasources/auth_preference_datasource.dart';
import '../../domain/auth_failures.dart';
import '../../domain/usecases/link_with_apple_usecase.dart';
import '../../domain/usecases/link_with_google_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_apple_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../auth_failure_message.dart';
import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LinkWithGoogleUseCase _linkWithGoogleUseCase;
  final LoginWithAppleUseCase _loginWithAppleUseCase;
  final LinkWithAppleUseCase _linkWithAppleUseCaseInstance;
  final AuthPreferenceDataSource _preferenceDataSource;
  final CcAnalytics _analytics;

  LoginBloc(
    this._loginUseCase,
    this._loginWithGoogleUseCase,
    this._linkWithGoogleUseCase,
    this._loginWithAppleUseCase,
    this._linkWithAppleUseCaseInstance,
    this._preferenceDataSource,
    this._analytics,
  ) : super(const LoginInitial()) {
    on<LoginStarted>(_onLoginStarted);
    on<LoginWithGoogleStarted>(
      (event, emit) => _runSocial(
        emit,
        action: _loginWithGoogleUseCase.call,
        method: 'google',
        label: 'LoginWithGoogle',
      ),
    );
    on<LinkWithGoogleStarted>(
      (event, emit) => _runSocial(
        emit,
        action: _linkWithGoogleUseCase.call,
        method: 'google',
        label: 'LinkWithGoogle',
      ),
    );
    on<LoginWithAppleStarted>(
      (event, emit) => _runSocial(
        emit,
        action: _loginWithAppleUseCase.call,
        method: 'apple',
        label: 'LoginWithApple',
      ),
    );
    on<LinkWithAppleStarted>(
      (event, emit) => _runSocial(
        emit,
        action: _linkWithAppleUseCaseInstance.call,
        method: 'apple',
        label: 'LinkWithApple',
      ),
    );
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

  /// Shared flow for Google/Apple sign-in and linking, so every provider and
  /// both modes behave the same: loading state, double-tap guard, analytics,
  /// typed cancel handling and localized errors.
  Future<void> _runSocial(
    Emitter<LoginState> emit, {
    required Future<Result<CcUserEntity, CcFailure>> Function() action,
    required String method,
    required String label,
  }) async {
    // A second tap while the provider sheet is open must not start another run.
    if (state is LoginLoading) return;

    emit(const LoginLoading());
    '$label started'.Log('LoginBloc');
    final result = await action();
    '$label result: ${result.isSuccess() ? "Success" : "Failure"}'.Log(
      'LoginBloc',
    );

    if (result.isSuccess()) {
      await _preferenceDataSource.setTermsAccepted(true);
    }
    result.when(
      (user) {
        '$label Success: ${user.id}'.Log('LoginBloc');
        // After linking hits `credential-already-in-use` the user id switches
        // to the existing account; setUserId keeps analytics on the new one.
        _analytics.logLogin(method: method);
        _analytics.setUserId(user.id);
        emit(LoginSuccess(user));
      },
      (failure) {
        '$label Failure: ${failure.message}'.Log('LoginBloc');
        if (failure is AuthCancelledFailure) {
          emit(const LoginCancelled());
        } else {
          emit(LoginError(authFailureMessage(failure)));
        }
      },
    );
  }
}
