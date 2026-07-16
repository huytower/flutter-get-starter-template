import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';

import '../../domain/usecases/sign_in_with_phone_number_usecase.dart';
import '../../domain/usecases/verify_phone_number_usecase.dart';
import '../../domain/phone_auth_status.dart';
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
      emit(const PhoneAuthError(CcLocaleKeys.validation_required));
      return;
    }

    _phoneNumber = event.phoneNumber;
    emit(const PhoneAuthLoading());

    try {
      final verificationStream = _verifyPhoneNumberUseCase(
        phoneNumber: event.phoneNumber,
      );

      await emit.forEach<PhoneAuthStatus>(
        verificationStream,
        onData: (status) {
          // If we already reached success (manually or automatically),
          // don't let background statuses (like timeouts) overwrite it.
          if (state is PhoneAuthSuccess) {
            return state;
          }

          if (status is PhoneAuthStatusCodeSent) {
            _verificationId = status.verificationId;
            return PhoneAuthCodeSent(
              status.verificationId,
              status.resendToken,
            );
          } else if (status is PhoneAuthStatusCompleted) {
            return PhoneAuthSuccess(status.user);
          } else if (status is PhoneAuthStatusFailed) {
            return PhoneAuthError(status.failure.message);
          } else if (status is PhoneAuthStatusAutoRetrievalTimeout) {
            // Keep the CodeSent state so the user can still enter the code manually
            return state;
          }
          return state;
        },
        onError: (error, stackTrace) {
          return const PhoneAuthError(CcLocaleKeys.app_error_general);
        },
      );
    } catch (e) {
      emit(const PhoneAuthError(CcLocaleKeys.app_error_general));
    }
  }

  Future<void> _onSignInWithCodeStarted(
    SignInWithCodeStarted event,
    Emitter<PhoneAuthState> emit,
  ) async {
    if (event.smsCode.isEmpty) {
      emit(const PhoneAuthError(CcLocaleKeys.validation_required));
      return;
    }

    if (_verificationId == null) {
      emit(const PhoneAuthError(CcLocaleKeys.app_error_general));
      return;
    }

    emit(const PhoneAuthLoading());

    final result = await _signInWithPhoneNumberUseCase(
      verificationId: _verificationId!,
      smsCode: event.smsCode,
    );

    result.when(
      (user) {
        emit(PhoneAuthSuccess(user));
      },
      (failure) {
        // Map failure message to specific OTP error locale keys
        final errorMessage = _mapOtpErrorToLocaleKey(failure.message);
        emit(PhoneAuthError(errorMessage));
      },
    );
  }

  String _mapOtpErrorToLocaleKey(String failureMessage) {
    // Firebase Auth error codes for OTP verification
    final lowerMessage = failureMessage.toLowerCase();

    if (lowerMessage.contains('invalid') ||
        lowerMessage.contains('wrong') ||
        lowerMessage.contains('incorrect')) {
      return CcLocaleKeys.auth_otp_invalid;
    }

    if (lowerMessage.contains('expired') || lowerMessage.contains('timeout')) {
      return CcLocaleKeys.auth_otp_expired;
    }

    if (lowerMessage.contains('too many') ||
        lowerMessage.contains('quota') ||
        lowerMessage.contains('attempts')) {
      return CcLocaleKeys.auth_otp_too_many_attempts;
    }

    // Default to general error if no specific match
    return failureMessage;
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
