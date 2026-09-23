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
          // If we already reached success, don't let background statuses overwrite it.
          if (state is PhoneAuthSuccess) {
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
            if (status.verificationId.isNotEmpty) {
              _verificationId = status.verificationId;
            }
            return state;
          }
          return state;
        },
        onError: (error, stackTrace) {
          'Phone Auth error in stream: $error'.Log('PhoneAuthBloc');
          if (state is PhoneAuthSuccess || _verificationId != null) {
            return state;
          }
          final msg = error is Exception
              ? error.toString().replaceAll('Exception: ', '')
              : error.toString();
          return PhoneAuthError(
            msg.isNotEmpty ? msg : 'Phone verification failed',
          );
        },
      );
    } catch (e) {
      'Phone Auth exception: $e'.Log('PhoneAuthBloc');
      final msg = e is Exception
          ? e.toString().replaceAll('Exception: ', '')
          : e.toString();
      emit(PhoneAuthError(msg.isNotEmpty ? msg : 'Phone verification failed'));
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

    if (_verificationId == null && state is PhoneAuthCodeSent) {
      _verificationId = (state as PhoneAuthCodeSent).verificationId;
    }

    if (_verificationId == null || _verificationId!.isEmpty) {
      'Cannot sign in: verificationId is null or empty'.Log('PhoneAuthBloc');
      emit(
        const PhoneAuthError(
          'Verification session expired or missing. Please resend code.',
        ),
      );
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
    if (failureMessage.isEmpty || failureMessage == 'An error occurred') {
      return 'Verification failed. Please try again or resend code.';
    }

    // Firebase Auth error codes for OTP verification
    final lowerMessage = failureMessage.toLowerCase();

    if (lowerMessage.contains('invalid') ||
        lowerMessage.contains('wrong') ||
        lowerMessage.contains('incorrect') ||
        lowerMessage.contains('invalid-verification-code')) {
      return 'Invalid OTP code. Please check and try again.';
    }

    if (lowerMessage.contains('expired') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('session-expired')) {
      return 'OTP code or session has expired. Please resend code.';
    }

    if (lowerMessage.contains('too many') ||
        lowerMessage.contains('quota') ||
        lowerMessage.contains('attempts') ||
        lowerMessage.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }

    // Default to concise detailed failure message
    return failureMessage;
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
