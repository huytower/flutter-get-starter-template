import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

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

    try {
      final verificationStream = _verifyPhoneNumberUseCase(
        phoneNumber: event.phoneNumber,
      );

      await emit.forEach<PhoneAuthEvent>(
        verificationStream,
        onData: (phoneEvent) {
          // If we already reached success (manually or automatically),
          // don't let background events (like timeouts) overwrite it.
          if (state is PhoneAuthSuccess) {
            return state;
          }

          if (phoneEvent is PhoneCodeSent) {
            _verificationId = phoneEvent.verificationId;
            return PhoneAuthCodeSent(
              phoneEvent.verificationId,
              phoneEvent.resendToken,
            );
          } else if (phoneEvent is PhoneVerificationCompleted) {
            return PhoneAuthSuccess(phoneEvent.user);
          } else if (phoneEvent is PhoneVerificationFailed) {
            return PhoneAuthError(phoneEvent.failure.message);
          } else if (phoneEvent is PhoneCodeAutoRetrievalTimeout) {
            // Keep the CodeSent state so the user can still enter the code manually
            return state;
          }
          return state;
        },
        onError: (error, stackTrace) {
          return const PhoneAuthError('An error occurred');
        },
      );
    } catch (e) {
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
      emit(const PhoneAuthError('An error occurred'));
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
        // Map failure message to specific OTP error messages
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
