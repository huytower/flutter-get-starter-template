// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:dio/dio.dart' as _i361;
import 'package:domain_features/export_domain_features.dart' as _i857;
import 'package:domain_features/features/comment/data/datasources/remote/comment_remote.dart'
    as _i130;
import 'package:domain_features/features/comment/data/repositories/comment_repository_impl.dart'
    as _i536;
import 'package:domain_features/features/crashlog/data/datasource/remote/crash_log_remote.dart'
    as _i580;
import 'package:domain_features/features/crashlog/data/repositories/crash_log_repository_impl.dart'
    as _i689;
import 'package:domain_features/features/crashlog/domain/repositories/crash_log_repository.dart'
    as _i473;
import 'package:domain_features/features/crashlog/domain/usecases/upload_pending_crash_logs_usecase.dart'
    as _i892;
import 'package:domain_features/features/examples/bloc_simple_page/cubit/simple/simple_cubit.dart'
    as _i691;
import 'package:domain_features/features/examples/bloc_simple_page/cubit/simple/simple_cubit_interface.dart'
    as _i402;
import 'package:domain_features/features/examples/bloc_simple_page/origin/advance/advance_bloc.dart'
    as _i1004;
import 'package:domain_features/features/home/data/datasources/remote/home_remote.dart'
    as _i55;
import 'package:domain_features/features/home/data/repositories/home_repository_impl.dart'
    as _i179;
import 'package:domain_features/features/home/domain/repositories/home_repository.dart'
    as _i269;
import 'package:domain_features/features/home/presentation/get_x/home_controller.dart'
    as _i971;
import 'package:injectable/injectable.dart' as _i526;

class DomainFeaturesPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    gh.lazySingleton<_i1004.AdvanceBloc>(
      () => _i1004.AdvanceBloc(),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i130.CommentRemote>(
        () => _i130.CommentRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i55.HomeRemote>(
        () => _i55.HomeRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i857.HomeRepository>(
        () => _i179.HomeRepositoryImpl(remote: gh<_i55.HomeRemote>()));
    gh.lazySingleton<_i402.SimpleCubitInterface>(
      () => _i691.SimpleCubit(),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i857.CommentRepository>(
        () => _i536.CommentRepositoryImpl(remote: gh<_i130.CommentRemote>()));
    gh.lazySingleton<_i580.CrashLogRemote>(
        () => _i580.CrashLogRemote(gh<_i361.Dio>(instanceName: 'baseDio')));
    gh.lazySingleton<_i971.HomeController>(
        () => _i971.HomeController(gh<_i269.HomeRepository>()));
    gh.lazySingleton<_i473.CrashLogRepository>(
        () => _i689.CrashLogRepositoryImpl(gh<_i580.CrashLogRemote>()));
    gh.lazySingleton<_i892.UploadPendingCrashLogsUseCase>(() =>
        _i892.UploadPendingCrashLogsUseCase(gh<_i473.CrashLogRepository>()));
  }
}
