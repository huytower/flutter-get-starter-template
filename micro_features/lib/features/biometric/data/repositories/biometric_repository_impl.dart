import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/biometric_auth_result_entity.dart';
import '../../domain/entities/biometric_auth_type_entity.dart';
import '../../domain/repositories/biometric_repository.dart';
import '../datasources/biometric_local_data_source.dart';

@LazySingleton(as: BiometricRepository)
class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricLocalDataSource _datasource;

  BiometricRepositoryImpl(this._datasource);

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
  Future<Result<BiometricAuthResultEntity, Exception>>
  authenticateWithBiometrics({
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
            : BiometricAuthTypeEntity.none;
        return Success(BiometricAuthResultEntity.success(authType: authType));
      } else {
        return Error(Exception('Authentication failed'));
      }
    } catch (e) {
      return Error(e is Exception ? e : Exception('Authentication error'));
    }
  }

  @override
  Future<Result<List<BiometricAuthTypeEntity>, Exception>>
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
