// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:app_config/core/di/module/dependencies.dart' as _i224;
import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart'
    as _i215;
import 'package:app_config/data/datasource/local/box/device_info/cc_device_info.dart'
    as _i494;
import 'package:app_config/data/datasource/remote/app_version_api.dart'
    as _i873;
import 'package:app_config/data/repositories/app_config_repository_impl.dart'
    as _i960;
import 'package:app_config/domain/repositories/app_config_repository.dart'
    as _i568;
import 'package:app_config/domain/usecases/check_update_required.dart' as _i88;
import 'package:app_config/domain/usecases/get_app_config.dart' as _i1011;
import 'package:app_config/domain/usecases/get_feature_flag.dart' as _i511;
import 'package:app_config/domain/usecases/refresh_app_config.dart' as _i597;
import 'package:injectable/injectable.dart' as _i526;

class AppConfigPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final appConfigDependencies = _$AppConfigDependencies();
    gh.lazySingleton<_i215.CcAppStorage>(
        () => appConfigDependencies.ccAppStorage);
    gh.lazySingleton<_i494.CcDeviceInfo>(
        () => appConfigDependencies.ccDeviceInfo);
    gh.lazySingleton<_i873.AppVersionAPI>(() => _i873.AppVersionAPI());
    gh.lazySingleton<_i568.AppConfigRepository>(
        () => _i960.AppConfigRepositoryImpl(gh<_i873.AppVersionAPI>()));
    gh.lazySingleton<_i88.CheckUpdateRequired>(
        () => _i88.CheckUpdateRequired(gh<_i568.AppConfigRepository>()));
    gh.lazySingleton<_i1011.GetAppConfig>(
        () => _i1011.GetAppConfig(gh<_i568.AppConfigRepository>()));
    gh.lazySingleton<_i511.GetFeatureFlag>(
        () => _i511.GetFeatureFlag(gh<_i568.AppConfigRepository>()));
    gh.lazySingleton<_i597.RefreshAppConfig>(
        () => _i597.RefreshAppConfig(gh<_i568.AppConfigRepository>()));
  }
}

class _$AppConfigDependencies extends _i224.AppConfigDependencies {}
