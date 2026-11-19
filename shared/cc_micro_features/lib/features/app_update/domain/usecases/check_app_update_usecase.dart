import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/app_update_config_entity.dart';
import '../entities/app_update_status_entity.dart';
import '../entities/app_version_entity.dart';
import '../entities/installed_app_entity.dart';
import '../repositories/app_update_config_repository.dart';
import '../repositories/app_update_repository.dart';

/// Decides whether the installed app must be updated before it can be used.
@lazySingleton
class CheckAppUpdateUseCase {
  const CheckAppUpdateUseCase(this._configRepository, this._appRepository);

  final AppUpdateConfigRepository _configRepository;
  final AppUpdateRepository _appRepository;

  Future<Result<AppUpdateStatusEntity, CcFailure>> call() async {
    final configResult = await _configRepository.getConfig();
    switch (configResult) {
      case Error(:final error):
        return Error(error);
      case Success(success: final config):
        // Skip the device lookup entirely when the flow is switched off.
        if (!config.isForce) return const Success(AppUpdateNotRequired());

        final installedResult = await _appRepository.getInstalledApp();
        return switch (installedResult) {
          Success(success: final installed) => Success(
            evaluate(config, installed),
          ),
          Error(:final error) => Error(error),
        };
    }
  }

  /// The pure decision rule: force is on, the platform has a store, a valid
  /// minimum is set, and the installed version is strictly below it.
  static AppUpdateStatusEntity evaluate(
    AppUpdateConfigEntity config,
    InstalledAppEntity installed,
  ) {
    if (!config.isForce || !installed.isStoreDistributed) {
      return const AppUpdateNotRequired();
    }
    final minimum = AppVersionEntity.tryParse(config.minimumVersion);
    if (minimum == null || !installed.version.isLowerThan(minimum)) {
      return const AppUpdateNotRequired();
    }
    return AppUpdateRequired(
      currentVersion: installed.version,
      minimumVersion: minimum,
    );
  }
}
