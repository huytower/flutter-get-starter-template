import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../entities/dashboard/dashboard_entity.dart';
import '../../repositories/dashboard/dashboard_repository.dart';

/// Update Dashboard Data Use Case - Domain Layer
@lazySingleton
class UpdateDashboardDataUseCase {
  final DashboardRepository repository;

  const UpdateDashboardDataUseCase(this.repository);

  /// Executes the use case to update dashboard data
  /// Returns a Future with Result containing updated DashboardEntity or Failure
  Future<Result<DashboardEntity, CcFailure>> call(
    DashboardEntity dashboardData,
  ) async {
    return await repository.updateDashboardData(dashboardData);
  }
}
