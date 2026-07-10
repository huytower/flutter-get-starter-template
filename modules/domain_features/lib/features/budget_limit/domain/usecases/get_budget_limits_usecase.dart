import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/budget_limit_entity.dart';
import '../repositories/budget_limit_repository.dart';

@lazySingleton
class GetBudgetLimitsUseCase {
  GetBudgetLimitsUseCase(this._repository);

  final BudgetLimitRepository _repository;

  Future<Result<List<BudgetLimitEntity>, CcFailure>> call({
    bool activeOnly = true,
  }) => _repository.getBudgets(activeOnly: activeOnly);
}
