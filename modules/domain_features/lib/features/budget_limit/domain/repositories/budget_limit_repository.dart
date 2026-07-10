import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/budget_limit_entity.dart';

abstract class BudgetLimitRepository {
  /// Budgets ordered by [BudgetLimitEntity.order]. When [activeOnly] is true,
  /// closed budgets are excluded.
  Future<Result<List<BudgetLimitEntity>, CcFailure>> getBudgets({
    bool activeOnly = true,
  });

  Future<Result<BudgetLimitEntity, CcFailure>> getBudget(String id);

  Future<Result<void, CcFailure>> createBudget(BudgetLimitEntity budget);

  Future<Result<void, CcFailure>> updateBudget(BudgetLimitEntity budget);

  Future<Result<void, CcFailure>> deleteBudget(String id);
}
