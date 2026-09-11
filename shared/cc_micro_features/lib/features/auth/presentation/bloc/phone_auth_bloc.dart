import 'dart:async';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/phone_auth_status.dart';
import '../../domain/usecases/sign_in_with_phone_number_usecase.dart';
import '../../domain/usecases/verify_phone_number_usecase.dart';
import 'phone_auth_event.dart';
import 'phone_auth_state.dart';

@injectable
class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final VerifyPhoneNumberUseCase _verifyPhoneNumberUseCase;
  final SignInWithPhoneNumberUseCase _signInWithPhoneNumberUseCase;
  String? _verificationId;
  String? _phoneNumber;

  PhoneAuthBloc(
    this._verifyPhoneNumberUseCase,
    this._signInWithPhoneNumberUseCase,
  ) : super(const PhoneAuthInitial()) {
    on<VerifyPhoneNumberStarted>(_onVerifyPhoneNumberStarted);
    on<SignInWithCodeStarted>(_onSignInWithCodeStarted);
    on<ResetPhoneAuthStarted>(_onResetPhoneAuthStarted);
    on<ClearPhoneAuthError>((event, emit) {
      if (state is PhoneAuthError) {
        emit(PhoneAuthCodeSent(_verificationId ?? '', null));
      }
    });
  }

  String? get phoneNumber => _phoneNumber;

  void _onResetPhoneAuthStarted(
    ResetPhoneAuthStarted event,
    Emitter<PhoneAuthState> emit,
  ) {
    _verificationId = null;
    _phoneNumber = null;
    emit(const PhoneAuthInitial());
  }

  Future<void> _onVerifyPhoneNumberStarted(
    VerifyPhoneNumberStarted event,
    Emitter<PhoneAuthState> emit,
  ) async {
    if (event.phoneNumber.isEmpty) {
      emit(const PhoneAuthError('This field is required'));
      return;
    }

    _phoneNumber = event.phoneNumber;
    emit(const PhoneAuthLoading());

    'Verifying phone number: ${event.phoneNumber}'.Log('PhoneAuthBloc');

    try {
      final verificationStream = _verifyPhoneNumberUseCase(
        phoneNumber: event.phoneNumber,
      );

      await emit.forEach<PhoneAuthStatus>(
        verificationStream,
        onData: (status) {
          'Phone Auth Status: $status'.Log('PhoneAuthBloc');
          // If we already reached success or are currently loading a manual
          // verification, don't let background statuses overwrite it.
          if (state is PhoneAuthSuccess || state is PhoneAuthLoading) {
            return state;
          }

          if (status is PhoneAuthStatusCodeSent) {
            'Code sent: ${status.verificationId}'.Log('PhoneAuthBloc');
            _verificationId = status.verificationId;
            return PhoneAuthCodeSent(status.verificationId, status.resendToken);
          } else if (status is PhoneAuthStatusCompleted) {
            'Phone Auth completed automatically: ${status.user.id}'.Log(
              'PhoneAuthBloc',
            );
            return PhoneAuthSuccess(status.user);
          } else if (status is PhoneAuthStatusFailed) {
            'Phone Auth failed in background stream: ${status.failure.message}'
                .Log('PhoneAuthBloc');
            // If we already have a verificationId, we are likely on the OTP screen.
            // A failure here is often a non-fatal auto-retrieval error.
            if (_verificationId != null) {
              return state;
            }
            return PhoneAuthError(status.failure.message);
          } else if (status is PhoneAuthStatusAutoRetrievalTimeout) {
            'Phone Auth auto retrieval timeout: ${status.verificationId}'.Log(
              'PhoneAuthBloc',
            );
            return state;
          }
          return state;
        },
        onError: (error, stackTrace) {
          'Phone Auth error in stream: $error'.Log('PhoneAuthBloc');
          if (state is PhoneAuthSuccess ||
              state is PhoneAuthLoading ||
              _verificationId != null) {
            return state;
          }
          return const PhoneAuthError('An error occurred');
        },
      );
    } catch (e) {
      'Phone Auth exception: $e'.Log('PhoneAuthBloc');
      emit(const PhoneAuthError('An error occurred'));
    }
  }

  Future<void> _onSignInWithCodeStarted(
    SignInWithCodeStarted event,
    Emitter<PhoneAuthState> emit,
  ) async {
    if (event.smsCode.isEmpty) {
      emit(const PhoneAuthError('This field is required'));
      return;
    }

    if (_verificationId == null) {
      'Cannot sign in: verificationId is null'.Log('PhoneAuthBloc');
      await CcCrashReportingHelper.recordHandledError(
        StateError('PhoneAuthBloc: verify tapped with null verificationId'),
        StackTrace.current,
        reason: 'PhoneAuthBloc._onSignInWithCodeStarted: verificationId lost '
            'before OTP submit',
      );
      emit(const PhoneAuthError('An error occurred'));
      return;
    }

    emit(const PhoneAuthLoading());

    'Signing in with code: ${event.smsCode} for id: $_verificationId'.Log(
      'PhoneAuthBloc',
    );

    final result = await _signInWithPhoneNumberUseCase(
      verificationId: _verificationId!,
      smsCode: event.smsCode,
    );

    result.when(
      (user) {
        emit(PhoneAuthSuccess(user));
      },
      (failure) {
        final errorMessage = _mapOtpErrorToMessage(failure.message);
        emit(PhoneAuthError(errorMessage));
      },
    );
  }

  String _mapOtpErrorToMessage(String failureMessage) {
    // Firebase Auth error codes for OTP verification
    final lowerMessage = failureMessage.toLowerCase();

    if (lowerMessage.contains('invalid') ||
        lowerMessage.contains('wrong') ||
        lowerMessage.contains('incorrect')) {
      return 'Invalid OTP code';
    }

    if (lowerMessage.contains('expired') || lowerMessage.contains('timeout')) {
      return 'OTP code has expired';
    }

    if (lowerMessage.contains('too many') ||
        lowerMessage.contains('quota') ||
        lowerMessage.contains('attempts')) {
      return 'Too many attempts. Please try again later';
    }

    // Default to general error if no specific match
    return failureMessage;
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
