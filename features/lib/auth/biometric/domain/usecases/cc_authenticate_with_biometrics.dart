import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/cc_biometric_auth_result.dart';
import '../repositories/cc_biometric_auth_repository.dart';

/// Parameters required for biometric authentication
class CcAuthenticateWithBiometricsParams {
  /// The message shown to the user in the authentication dialog
  final String localizedReason;

  /// Whether to show system dialogs for errors
  final bool useErrorDialogs;

  /// Whether to keep the authentication dialog open when the app goes to background
  final bool stickyAuth;

  const CcAuthenticateWithBiometricsParams({
    required this.localizedReason,
    this.useErrorDialogs = true,
    this.stickyAuth = false,
  });
}

/// Use case for authenticating with biometrics
@lazySingleton
class CcAuthenticateWithBiometrics {
  final CcBiometricAuthRepository repository;

  const CcAuthenticateWithBiometrics(this.repository);

  /// Executes the authentication with biometrics
  Future<Result<CcBiometricAuthResult, Exception>> call(
    CcAuthenticateWithBiometricsParams params,
  ) async {
    try {
      // First check if biometrics are available
      final isAvailable = await repository.isBiometricAvailable();

      return await isAvailable.when((success) async {
        if (!success) {
          return Error(Exception('Biometric authentication not available'));
        }

        // If available, proceed with authentication
        final result = await repository.authenticateWithBiometrics(
          localizedReason: params.localizedReason,
          useErrorDialogs: params.useErrorDialogs,
          stickyAuth: params.stickyAuth,
        );

        return result;
      }, (error) => Error(error));
    } catch (e) {
      return Error(e is Exception ? e : Exception('Authentication failed'));
    }
  }
}
