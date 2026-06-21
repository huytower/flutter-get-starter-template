import 'package:cc_sdk/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../entities/home/home_entity.dart';

///
/// This abstract interface defines the contract for dashboard data operations.
/// It follows the Dependency Inversion Principle by depending on abstractions,
/// not concrete implementations.
abstract class HomeRepository {
  /// Retrieves the home data
  /// Returns a Future with Result containing HomeEntity or Failure
  Future<Result<HomeEntity, CcFailure>> getHomeData();
}
