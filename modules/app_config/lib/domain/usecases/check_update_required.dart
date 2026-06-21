import 'package:cc_sdk/domain/failures/app_config/cc_app_config_failure.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/app_config_repository.dart';

/// Use case for checking if an app update is required.
@lazySingleton
class CheckUpdateRequired {
  final AppConfigRepository repository;

  const CheckUpdateRequired(this.repository);

  /// Checks if an update is required for the given [currentVersion].
  ///
  /// Returns a [Result] containing either a [CcFailure] or a [bool] indicating if an update is required.
  Future<Result<bool, CcFailure>> call(String currentVersion) async {
    try {
      final isRequired = await repository.isUpdateRequired(currentVersion);
      return Success(isRequired);
    } on CcFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(CcConfigFailure('Failed to check update requirement: $e'));
    }
  }
}
