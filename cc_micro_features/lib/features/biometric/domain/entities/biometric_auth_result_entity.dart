import 'package:equatable/equatable.dart';

import 'biometric_auth_type_entity.dart';

/// Represents the result of a biometric authentication attempt
class BiometricAuthResultEntity extends Equatable {
  /// Whether the authentication was successful
  final bool isAuthenticated;

  /// Optional error message if authentication failed
  final String? errorMessage;

  /// Type of biometric authentication used
  final BiometricAuthTypeEntity authType;

  const BiometricAuthResultEntity({
    required this.isAuthenticated,
    this.errorMessage,
    required this.authType,
  });

  /// Creates a successful authentication result
  const BiometricAuthResultEntity.success({
    required BiometricAuthTypeEntity authType,
  }) : isAuthenticated = true,
       errorMessage = null,
       authType = authType;

  /// Creates a failed authentication result
  const BiometricAuthResultEntity.failure({
    required String errorMessage,
    required BiometricAuthTypeEntity authType,
  }) : isAuthenticated = false,
       errorMessage = errorMessage,
       authType = authType;

  @override
  List<Object?> get props => [isAuthenticated, errorMessage, authType];
}
