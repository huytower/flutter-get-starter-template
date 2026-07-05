import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  /// Budgets ordered by [BudgetEntity.order]. When [activeOnly] is true,
  /// closed budgets are excluded.
  Future<Result<List<BudgetEntity>, CcFailure>> getBudgets({
    bool activeOnly = true,
  });

  Future<Result<BudgetEntity, CcFailure>> getBudget(String id);

  Future<Result<void, CcFailure>> createBudget(BudgetEntity budget);

  Future<Result<void, CcFailure>> updateBudget(BudgetEntity budget);

  Future<Result<void, CcFailure>> deleteBudget(String id);
}
