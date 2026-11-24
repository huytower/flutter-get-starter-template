import 'package:equatable/equatable.dart';

import 'biometric_auth_type_entity.dart';

/// Represents the result of a biometric authentication attempt
class BiometricAuthResultEntity extends Equatable {
  /// Whether the authentication was successful
  final bool hasAuthenticated;

  /// Optional error message if authentication failed
  final String? errorMessage;

  /// Type of biometric authentication used
  final BiometricAuthTypeEntity authType;

  const BiometricAuthResultEntity({
    required this.hasAuthenticated,
    this.errorMessage,
    required this.authType,
  });

  /// Creates a successful authentication result
  const BiometricAuthResultEntity.success({
    required BiometricAuthTypeEntity authType,
  }) : hasAuthenticated = true,
       errorMessage = null,
       authType = authType;

  /// Creates a failed authentication result
  const BiometricAuthResultEntity.failure({
    required String errorMessage,
    required BiometricAuthTypeEntity authType,
  }) : hasAuthenticated = false,
       errorMessage = errorMessage,
       authType = authType;

  @override
  List<Object?> get props => [hasAuthenticated, errorMessage, authType];
}
