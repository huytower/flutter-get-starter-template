import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../entities/dashboard/dashboard_entity.dart';
import '../../repositories/dashboard/dashboard_repository.dart';

/// Refresh Dashboard Data Use Case - Domain Layer
@lazySingleton
class RefreshDashboardDataUseCase {
  final DashboardRepository repository;

  const RefreshDashboardDataUseCase(this.repository);

  /// Executes the use case to refresh dashboard data
  /// Returns a Future with Result containing DashboardEntity or Failure
  Future<Result<DashboardEntity, CcFailure>> call() async {
    return await repository.refreshDashboardData();
  }
}
