// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart'
    as _i215;
import 'package:data/core/di/di.dart' as _i1010;
import 'package:data/core/di/module/data_module.dart' as _i532;
import 'package:data/data/datasource/local/dashboard/dashboard_local_datasource.dart'
    as _i966;
import 'package:data/data/datasource/local/dashboard/dashboard_local_datasource_impl.dart'
    as _i774;
import 'package:data/data/datasource/remote/comment/comment_remote.dart'
    as _i574;
import 'package:data/data/datasource/remote/crash_log/crash_log_remote.dart'
    as _i313;
import 'package:data/data/datasource/remote/dashboard/dashboard_remote_datasource.dart'
    as _i480;
import 'package:data/data/datasource/remote/dashboard/dashboard_remote_datasource_impl.dart'
    as _i434;
import 'package:data/data/datasource/remote/home/home_remote.dart' as _i516;
import 'package:data/data/repositories/auth/firebase_auth_repository_impl.dart'
    as _i733;
import 'package:data/data/repositories/comment/comment_repository_impl.dart'
    as _i576;
import 'package:data/data/repositories/crash_log/crash_log_repository_impl.dart'
    as _i701;
import 'package:data/data/repositories/dashboard/dashboard_repository_impl.dart'
    as _i254;
import 'package:data/data/repositories/home/home_repository_impl.dart' as _i114;
import 'package:data/domain/repositories/auth/cc_auth_repository.dart' as _i475;
import 'package:data/domain/repositories/comment/comment_repository.dart'
    as _i683;
import 'package:data/domain/repositories/crash_log/crash_log_repository.dart'
    as _i63;
import 'package:data/domain/repositories/dashboard/dashboard_repository.dart'
    as _i866;
import 'package:data/domain/usecases/dashboard/get_dashboard_data_usecase.dart'
    as _i208;
import 'package:data/domain/usecases/dashboard/refresh_dashboard_data_usecase.dart'
    as _i393;
import 'package:data/domain/usecases/dashboard/update_dashboard_data_usecase.dart'
    as _i695;
import 'package:data/domain/usecases/upload_pending_crash_logs_usecase.dart'
    as _i813;
import 'package:data/export_data.dart' as _i859;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

class DataPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final firebaseModule = _$FirebaseModule();
    final dataModule = _$DataModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.singleton<_i361.Interceptor>(
      () => dataModule.ccResponseInterceptor,
      instanceName: 'ccResponseInterceptor',
    );
    gh.singleton<_i361.Interceptor>(
      () => dataModule.cacheInterceptor,
      instanceName: 'cacheInterceptor',
    );
    gh.factory<String>(
      () => dataModule.baseUrl,
      instanceName: 'baseUrl',
    );
    gh.singleton<_i361.Interceptor>(
      () => dataModule.talkerDioLogger,
      instanceName: 'talkerDioLogger',
    );
    gh.lazySingleton<_i966.DashboardLocalDataSource>(
        () => _i774.DashboardLocalDataSourceImpl(gh<_i215.CcAppStorage>()));
    gh.singleton<_i361.Interceptor>(
      () => dataModule.ccRequestInterceptor,
      instanceName: 'ccRequestInterceptor',
    );
    gh.singleton<_i361.Interceptor>(
      () => dataModule.curlLoggerInterceptor,
      instanceName: 'curlLoggerInterceptor',
    );
    gh.lazySingleton<_i480.DashboardRemoteDataSource>(
        () => const _i434.DashboardRemoteDataSourceImpl());
    gh.singleton<List<_i361.Interceptor>>(() => dataModule.interceptors(
          gh<_i361.Interceptor>(instanceName: 'ccRequestInterceptor'),
          gh<_i361.Interceptor>(instanceName: 'ccResponseInterceptor'),
          gh<_i361.Interceptor>(instanceName: 'curlLoggerInterceptor'),
          gh<_i361.Interceptor>(instanceName: 'talkerDioLogger'),
          gh<_i361.Interceptor>(instanceName: 'cacheInterceptor'),
        ));
    gh.lazySingleton<_i475.CcAuthRepository>(
        () => _i733.FirebaseAuthRepositoryImpl(
              gh<_i59.FirebaseAuth>(),
              gh<_i116.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i361.BaseOptions>(
        () => dataModule.baseOptions(gh<String>(instanceName: 'baseUrl')));
    gh.lazySingleton<_i866.DashboardRepository>(
        () => _i254.DashboardRepositoryImpl(
              localDataSource: gh<_i966.DashboardLocalDataSource>(),
              remoteDataSource: gh<_i480.DashboardRemoteDataSource>(),
            ));
    gh.lazySingleton<_i361.Dio>(
      () => dataModule.dio(
        gh<_i361.BaseOptions>(),
        gh<List<_i361.Interceptor>>(),
      ),
      instanceName: 'baseDio',
    );
    gh.lazySingleton<_i313.CrashLogRemote>(
        () => _i313.CrashLogRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i208.GetDashboardDataUseCase>(
        () => _i208.GetDashboardDataUseCase(gh<_i866.DashboardRepository>()));
    gh.lazySingleton<_i393.RefreshDashboardDataUseCase>(() =>
        _i393.RefreshDashboardDataUseCase(gh<_i866.DashboardRepository>()));
    gh.lazySingleton<_i695.UpdateDashboardDataUseCase>(() =>
        _i695.UpdateDashboardDataUseCase(gh<_i866.DashboardRepository>()));
    gh.lazySingleton<_i63.CrashLogRepository>(
        () => _i701.CrashLogRepositoryImpl(gh<_i313.CrashLogRemote>()));
    gh.singleton<_i574.CommentRemote>(
        () => _i574.CommentRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.singleton<_i516.HomeRemote>(
        () => _i516.HomeRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i813.UploadPendingCrashLogsUseCase>(() =>
        _i813.UploadPendingCrashLogsUseCase(gh<_i63.CrashLogRepository>()));
    gh.singleton<_i859.HomeRepository>(
        () => _i114.HomeRepositoryImpl(remote: gh<_i516.HomeRemote>()));
    gh.singleton<_i683.CommentRepository>(
        () => _i576.CommentRepositoryImpl(remote: gh<_i574.CommentRemote>()));
  }
}

class _$FirebaseModule extends _i1010.FirebaseModule {}

class _$DataModule extends _i532.DataModule {}
