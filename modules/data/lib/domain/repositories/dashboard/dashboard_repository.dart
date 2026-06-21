import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../entities/dashboard/dashboard_entity.dart';

/// Dashboard Repository Interface - Domain Layer
///
/// This abstract interface defines the contract for dashboard data operations.
/// It follows the Dependency Inversion Principle by depending on abstractions,
/// not concrete implementations.
abstract class DashboardRepository {
  /// Retrieves the dashboard data
  /// Returns a Future with Result containing DashboardEntity or Failure
  Future<Result<DashboardEntity, CcFailure>> getDashboardData();

  /// Updates the dashboard data
  /// Takes a DashboardEntity and returns a Future with Result containing updated entity or Failure
  Future<Result<DashboardEntity, CcFailure>> updateDashboardData(
    DashboardEntity dashboardData,
  );

  /// Refreshes the dashboard data from the source
  /// Returns a Future with Result containing refreshed DashboardEntity or Failure
  Future<Result<DashboardEntity, CcFailure>> refreshDashboardData();
}
