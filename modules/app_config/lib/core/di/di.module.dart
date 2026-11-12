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
  }
}

class _$AppConfigDependencies extends _i224.AppConfigDependencies {}
