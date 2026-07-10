import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

@lazySingleton
class GetBudgetsUseCase {
  GetBudgetsUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Result<List<BudgetEntity>, CcFailure>> call({
    bool activeOnly = true,
  }) =>
      _repository.getBudgets(activeOnly: activeOnly);
}
