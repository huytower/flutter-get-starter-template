// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:cc_bridge/export_cc_bridge.dart' as _i727;
import 'package:data_config/core/di/di.dart' as _i177;
import 'package:data_config/core/di/module/data_module.dart' as _i291;
import 'package:data_config/core/util/firestore_sync_service.dart' as _i954;
import 'package:data_config/core/util/generic_sync_datasource.dart' as _i312;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

class DataConfigPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final firebaseModule = _$FirebaseModule();
    final dataModule = _$DataModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i954.FirestoreSyncService>(
        () => _i954.FirestoreSyncService());
    gh.lazySingleton<_i361.Interceptor>(
      () => dataModule.cacheInterceptor,
      instanceName: 'cacheInterceptor',
    );
    gh.factory<String>(
      () => dataModule.baseUrl,
      instanceName: 'baseUrl',
    );
    gh.lazySingleton<_i361.Interceptor>(
      () => dataModule.talkerDioLogger,
      instanceName: 'talkerDioLogger',
    );
    gh.lazySingleton<_i361.Interceptor>(
      () => dataModule.curlLoggerInterceptor,
      instanceName: 'curlLoggerInterceptor',
    );
    gh.lazySingleton<_i361.Interceptor>(
      () => dataModule.requestInterceptor,
      instanceName: 'requestInterceptor',
    );
    gh.lazySingleton<_i361.Interceptor>(
      () => dataModule.responseInterceptor,
      instanceName: 'responseInterceptor',
    );
    gh.lazySingleton<List<_i361.Interceptor>>(() => dataModule.interceptors(
          gh<_i361.Interceptor>(instanceName: 'requestInterceptor'),
          gh<_i361.Interceptor>(instanceName: 'responseInterceptor'),
          gh<_i361.Interceptor>(instanceName: 'curlLoggerInterceptor'),
          gh<_i361.Interceptor>(instanceName: 'talkerDioLogger'),
          gh<_i361.Interceptor>(instanceName: 'cacheInterceptor'),
        ));
    gh.factory<_i312.GenericSyncDataSource>(() => _i312.GenericSyncDataSource(
          gh<_i954.FirestoreSyncService>(),
          gh<_i727.SessionContract>(),
          gh<String>(),
        ));
    gh.lazySingleton<_i361.BaseOptions>(
        () => dataModule.baseOptions(gh<String>(instanceName: 'baseUrl')));
    gh.lazySingleton<_i361.Dio>(
      () => dataModule.dio(
        gh<_i361.BaseOptions>(),
        gh<List<_i361.Interceptor>>(),
      ),
      instanceName: 'baseDio',
    );
  }
}

class _$FirebaseModule extends _i177.FirebaseModule {}

class _$DataModule extends _i291.DataModule {}
