import 'package:equatable/equatable.dart';

import 'cc_biometric_auth_type.dart';

/// Represents the result of a biometric authentication attempt
class CcBiometricAuthResult extends Equatable {
  /// Whether the authentication was successful
  final bool isAuthenticated;

  /// Optional error message if authentication failed
  final String? errorMessage;

  /// Type of biometric authentication used
  final CcBiometricAuthType authType;

  const CcBiometricAuthResult({
    required this.isAuthenticated,
    this.errorMessage,
    required this.authType,
  });

  /// Creates a successful authentication result
  const CcBiometricAuthResult.success({required CcBiometricAuthType authType})
    : isAuthenticated = true,
      errorMessage = null,
      authType = authType;

  /// Creates a failed authentication result
  const CcBiometricAuthResult.failure({
    required String errorMessage,
    required CcBiometricAuthType authType,
  }) : isAuthenticated = false,
       errorMessage = errorMessage,
       authType = authType;

  @override
  List<Object?> get props => [isAuthenticated, errorMessage, authType];
}
