import 'dart:async';

import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:data/data/datasource/remote/home/home_remote.dart';
import 'package:data/export_data.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../core/repository/cc_base_repository.dart';
import '../../../domain/entities/home/home_entity.dart';

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
