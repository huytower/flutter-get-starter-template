import 'dart:async';

import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../datasources/remote/home_remote.dart';

@Singleton(as: HomeRepository)
class HomeRepositoryImpl with CcBaseRepository implements HomeRepository {
  @factoryMethod
  HomeRepositoryImpl({required HomeRemote remote}) : _remote = remote;

  final HomeRemote _remote;

  @override
  Future<Result<HomeEntity, CcFailure>> getHomeData() {
    throw UnimplementedError();
  }
}
