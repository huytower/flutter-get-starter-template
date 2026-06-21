import 'package:cc_sdk/domain/failures/app_config/cc_app_config_failure.dart';
import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/app_config_entity.dart';
import '../repositories/app_config_repository.dart';

/// Use case for refreshing the application configuration.
@lazySingleton
class RefreshAppConfig {
  final AppConfigRepository repository;

  const RefreshAppConfig(this.repository);

  /// Refreshes the app configuration from the remote source.
  ///
  /// Returns a [Result] containing either a [CcFailure] or the updated [AppConfigEntity].
  Future<Result<AppConfigEntity, CcFailure>> call() async {
    try {
      final config = await repository.refreshConfig();
      return Success(config);
    } on CcFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(CcConfigFailure('Failed to refresh app config: $e'));
    }
  }
}
