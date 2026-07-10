import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/budget_limit_repository.dart';

/// Soft-deletes a budget: it is archived (hidden from active queries) but the
/// record stays in storage.
@lazySingleton
class DeleteBudgetLimitUseCase {
  DeleteBudgetLimitUseCase(this._repository);

  final BudgetLimitRepository _repository;

  Future<Result<void, CcFailure>> call(String id) async {
    final budgetResult = await _repository.getBudget(id);
    if (budgetResult.isError()) {
      return Error(budgetResult.tryGetError()!);
    }
    final budget = budgetResult.tryGetSuccess()!;
    final updateResult = await _repository.updateBudget(
      budget.copyWith(isClosed: true),
    );
    if (updateResult.isError()) {
      return Error(updateResult.tryGetError()!);
    }
    return const Success(null);
  }
}
