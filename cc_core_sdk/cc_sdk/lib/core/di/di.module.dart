// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:cc_sdk/core/di/module/cc_dependencies.dart' as _i1021;
import 'package:cc_sdk/core/helper/cc_device_helper.dart' as _i918;
import 'package:cc_sdk/core/helper/cc_device_info_helper.dart' as _i312;
import 'package:cc_sdk/core/helper/cc_network_helper.dart' as _i548;
import 'package:cc_sdk/core/helper/cc_responsive_helper.dart' as _i987;
import 'package:cc_sdk/core/network/cc_network_info.dart' as _i13;
import 'package:cc_sdk/domain/entities/cc_device_entity.dart' as _i739;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:device_info_plus/device_info_plus.dart' as _i833;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

class CcSdkPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) async {
    final ccSdkDependencies = _$CcSdkDependencies();
    gh.factory<_i918.CcDeviceHelper>(() => _i918.CcDeviceHelper());
    gh.factory<_i987.CcResponsiveHelper>(() => _i987.CcResponsiveHelper());
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => ccSdkDependencies.sharedPreferences,
      preResolve: true,
    );
    gh.singleton<_i161.InternetConnection>(
        () => ccSdkDependencies.internetConnection);
    gh.singleton<_i895.Connectivity>(() => ccSdkDependencies.connectivity);
    gh.singleton<_i833.DeviceInfoPlugin>(
        () => ccSdkDependencies.deviceInfoPlugin);
    gh.singleton<_i13.CcNetworkInfo>(
        () => _i13.CcNetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.singleton<_i548.CcNetworkHelper>(
        () => _i548.CcNetworkHelper(gh<_i161.InternetConnection>()));
    gh.lazySingleton<_i312.CcDeviceInfoHelper>(
        () => _i312.CcDeviceInfoHelper(gh<_i833.DeviceInfoPlugin>()));
    await gh.singletonAsync<_i739.CcDeviceEntity>(
      () => ccSdkDependencies.deviceModel(gh<_i312.CcDeviceInfoHelper>()),
      preResolve: true,
    );
  }
}

class _$CcSdkDependencies extends _i1021.CcSdkDependencies {}
