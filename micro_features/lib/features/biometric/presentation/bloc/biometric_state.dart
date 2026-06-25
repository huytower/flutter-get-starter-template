part of 'biometric_bloc.dart';

abstract class BiometricState extends Equatable {
  const BiometricState();

  @override
  List<Object?> get props => [];
}

class BiometricInitial extends BiometricState {}

class BiometricLoading extends BiometricState {}

class BiometricAvailable extends BiometricState {
  final bool isAvailable;
  final List<BiometricAuthTypeEntity> types;

  const BiometricAvailable({required this.isAvailable, required this.types});

  @override
  List<Object?> get props => [isAvailable, types];
}

class BiometricAuthenticated extends BiometricState {
  final BiometricAuthResultEntity result;

  const BiometricAuthenticated({required this.result});

  @override
  List<Object?> get props => [result];
}

class BiometricError extends BiometricState {
  final String message;

  const BiometricError({required this.message});

  @override
  List<Object?> get props => [message];
}
