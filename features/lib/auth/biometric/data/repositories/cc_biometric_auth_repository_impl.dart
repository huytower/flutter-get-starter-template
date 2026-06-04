import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/cc_biometric_auth_result.dart';
import '../../domain/entities/cc_biometric_auth_type.dart';
import '../../domain/repositories/cc_biometric_auth_repository.dart';
import '../datasources/local/cc_biometric_auth_datasource.dart';

@LazySingleton(as: CcBiometricAuthRepository)
class CcBiometricAuthRepositoryImpl implements CcBiometricAuthRepository {
  final CcBiometricAuthDatasource _datasource;

  CcBiometricAuthRepositoryImpl(this._datasource);

  @override
  Future<Result<bool, Exception>> isBiometricAvailable() async {
    try {
      final isAvailable = await _datasource.isBiometricAvailable();
      return Success(isAvailable);
    } catch (e) {
      return Error(
        e is Exception
            ? e
            : Exception('Failed to check biometric availability'),
      );
    }
  }

  @override
  Future<Result<CcBiometricAuthResult, Exception>> authenticateWithBiometrics({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final isAuthenticated = await _datasource.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        sensitiveTransaction: true,
      );

      if (isAuthenticated) {
        final biometrics = await _datasource.getAvailableBiometrics();
        final authType = biometrics.isNotEmpty
            ? biometrics.first
            : CcBiometricAuthType.none;
        return Success(CcBiometricAuthResult.success(authType: authType));
      } else {
        return Error(Exception('Authentication failed'));
      }
    } catch (e) {
      return Error(e is Exception ? e : Exception('Authentication error'));
    }
  }

  @override
  Future<Result<List<CcBiometricAuthType>, Exception>>
  getAvailableBiometrics() async {
    try {
      final biometrics = await _datasource.getAvailableBiometrics();
      return Success(biometrics);
    } catch (e) {
      return Error(
        e is Exception ? e : Exception('Failed to get available biometrics'),
      );
    }
  }
}
