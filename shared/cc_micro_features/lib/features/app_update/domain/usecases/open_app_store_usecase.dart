import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/app_update_config_repository.dart';
import '../repositories/app_update_repository.dart';

/// Opens the store page where the user can install the required update.
@lazySingleton
class OpenAppStoreUseCase {
  const OpenAppStoreUseCase(this._configRepository, this._appRepository);

  final AppUpdateConfigRepository _configRepository;
  final AppUpdateRepository _appRepository;

  Future<Result<Unit, CcFailure>> call() async {
    final configResult = await _configRepository.getConfig();
    return switch (configResult) {
      Success(success: final config) => _appRepository.openStore(
        iosAppStoreId: config.iosAppStoreId,
        androidPackageName: config.androidPackageName,
      ),
      Error(:final error) => Error(error),
    };
  }
}
