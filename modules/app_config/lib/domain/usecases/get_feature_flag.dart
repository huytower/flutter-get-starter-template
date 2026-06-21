import 'package:cc_sdk/domain/failures/app_config/cc_app_config_failure.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/app_config_repository.dart';

/// Use case for getting a feature flag value.
@lazySingleton
class GetFeatureFlag {
  final AppConfigRepository repository;

  const GetFeatureFlag(this.repository);

  /// Gets the value of a feature flag with the given [key].
  ///
  /// Returns a [Result] containing either a [CcFailure] or the feature flag value.
  /// If the key doesn't exist, returns the [defaultValue].
  Future<Result<T, CcFailure>> call<T>(
    String key, {
    required T defaultValue,
  }) async {
    try {
      final value = await repository.getFeatureFlag<T>(
        key,
        defaultValue: defaultValue,
      );
      return Success(value);
    } on CcFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(CcConfigFailure('Failed to get feature flag: $e'));
    }
  }
}
