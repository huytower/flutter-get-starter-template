import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../core/repository/cc_base_repository.dart';
import '../../../domain/entities/dashboard/dashboard_entity.dart';
import '../../../domain/repositories/dashboard/dashboard_repository.dart';
import '../../datasource/local/dashboard/dashboard_local_datasource.dart';
import '../../datasource/remote/dashboard/dashboard_remote_datasource.dart';

/// Dashboard Repository Implementation - Data Layer
@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl
    with CcBaseRepository
    implements DashboardRepository {
  final DashboardLocalDataSource _localDataSource;
  final DashboardRemoteDataSource _remoteDataSource;

  const DashboardRepositoryImpl({
    required DashboardLocalDataSource localDataSource,
    required DashboardRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<Result<DashboardEntity, Failure>> getDashboardData() async {
    return safeRequest(() async {
      try {
        final localData = await _localDataSource.getDashboardData();
        final isDataFresh =
            DateTime.now().difference(localData.lastUpdated).inHours < 1;

        if (isDataFresh) {
          return localData;
        }

        try {
          final remoteData = await _remoteDataSource.fetchDashboardData();
          await _localDataSource.saveDashboardData(remoteData);
          return remoteData;
        } catch (e) {
          return localData;
        }
      } catch (e) {
        // Fallback to remote if local fails entirely
        final remoteData = await _remoteDataSource.fetchDashboardData();
        await _localDataSource.saveDashboardData(remoteData);
        return remoteData;
      }
    });
  }

  @override
  Future<Result<DashboardEntity, Failure>> updateDashboardData(
    DashboardEntity dashboardData,
  ) async {
    return safeRequest(() async {
      try {
        final updatedRemoteData = await _remoteDataSource.updateDashboardData(
          dashboardData,
        );
        await _localDataSource.saveDashboardData(updatedRemoteData);
        return updatedRemoteData;
      } catch (e) {
        // Optimistic update or local fallback if remote fails
        await _localDataSource.saveDashboardData(dashboardData);
        return dashboardData;
      }
    });
  }

  @override
  Future<Result<DashboardEntity, Failure>> refreshDashboardData() async {
    return safeRequest(() async {
      final freshData = await _remoteDataSource.fetchDashboardData();
      await _localDataSource.saveDashboardData(freshData);
      return freshData;
    });
  }
}
