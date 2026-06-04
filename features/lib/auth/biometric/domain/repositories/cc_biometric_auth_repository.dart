import 'package:multiple_result/multiple_result.dart';

import '../entities/cc_biometric_auth_result.dart';
import '../entities/cc_biometric_auth_type.dart';

abstract class CcBiometricAuthRepository {
  /// Checks if biometric authentication is available on the device
  Future<Result<bool, Exception>> isBiometricAvailable();

  /// Authenticates the user using biometrics
  ///
  /// [localizedReason] is the message shown to the user in the authentication dialog
  /// [useErrorDialogs] whether to show system dialogs for errors
  /// [stickyAuth] whether to keep the authentication dialog open when the app goes to background
  Future<Result<CcBiometricAuthResult, Exception>> authenticateWithBiometrics({
    required String localizedReason,
    bool useErrorDialogs,
    bool stickyAuth,
  });

  /// Gets the list of available biometric types
  Future<Result<List<CcBiometricAuthType>, Exception>> getAvailableBiometrics();
}
