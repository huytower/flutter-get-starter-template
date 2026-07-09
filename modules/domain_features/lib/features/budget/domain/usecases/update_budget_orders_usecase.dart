import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

/// Persists a user-chosen display order: each budget's `order` becomes its
/// index in [orderedIds] (budgets not listed are left untouched).
@lazySingleton
class UpdateBudgetOrdersUseCase {
  UpdateBudgetOrdersUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Result<void, CcFailure>> call(List<String> orderedIds) async {
    final budgetsResult = await _repository.getBudgets(activeOnly: true);
    if (budgetsResult.isError()) {
      return Error(budgetsResult.tryGetError()!);
    }
    final byId = {for (final b in budgetsResult.tryGetSuccess()!) b.id: b};

    // Collect only the budgets that actually need a new order value.
    final toUpdate = <({BudgetEntity original, BudgetEntity updated})>[];
    for (var index = 0; index < orderedIds.length; index++) {
      final budget = byId[orderedIds[index]];
      if (budget == null || budget.order == index) continue;
      toUpdate.add((original: budget, updated: budget.copyWith(order: index)));
    }

    // Write sequentially, rolling back already-written items on failure so
    // storage is never left with a partially-applied order.
    final written = <BudgetEntity>[];
    for (final pair in toUpdate) {
      final result = await _repository.updateBudget(pair.updated);
      if (result.isError()) {
        for (final original in written) {
          await _repository.updateBudget(original);
        }
        return Error(result.tryGetError()!);
      }
      written.add(pair.original);
    }
    return const Success(null);
  }
}
