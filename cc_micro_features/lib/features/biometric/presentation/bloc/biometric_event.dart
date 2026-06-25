part of 'biometric_bloc.dart';

abstract class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object?> get props => [];
}

class CheckBiometricAvailability extends BiometricEvent {}

class AuthenticateWithBiometric extends BiometricEvent {
  final String localizedReason;

  const AuthenticateWithBiometric({required this.localizedReason});

  @override
  List<Object?> get props => [localizedReason];
}
