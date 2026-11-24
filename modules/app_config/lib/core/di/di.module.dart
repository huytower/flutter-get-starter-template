// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:app_config/core/di/module/app_config_dependencies.dart' as _i33;
import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart'
    as _i145;
import 'package:app_config/data/datasources/local/box/device_info/prj_device_info.dart'
    as _i776;
import 'package:injectable/injectable.dart' as _i526;

class AppConfigPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final appConfigDependencies = _$AppConfigDependencies();
    gh.lazySingleton<_i145.PrjAppStorage>(
        () => appConfigDependencies.ccAppStorage);
    gh.lazySingleton<_i776.PrjDeviceInfo>(
        () => appConfigDependencies.ccDeviceInfo);
  }
}

class _$AppConfigDependencies extends _i33.AppConfigDependencies {}
