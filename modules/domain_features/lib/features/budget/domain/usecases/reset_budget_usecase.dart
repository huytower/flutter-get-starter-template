import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';
import 'create_budget_usecase.dart';

/// Closes an old budget and opens a fresh one at the same order
/// (mirrors `ResetNganSachUseCase`).
@lazySingleton
class ResetBudgetUseCase {
  ResetBudgetUseCase(this._repository, this._createBudgetUseCase);

  final BudgetRepository _repository;
  final CreateBudgetUseCase _createBudgetUseCase;

  Future<Result<BudgetEntity, CcFailure>> call(
    String oldId,
    CreateBudgetParams newData,
  ) async {
    final oldResult = await _repository.getBudget(oldId);
    if (oldResult.isError()) {
      return Error(oldResult.tryGetError()!);
    }
    final old = oldResult.tryGetSuccess()!;

    // 1. Archive the old budget.
    final closeResult =
        await _repository.updateBudget(old.copyWith(isClosed: true));
    if (closeResult.isError()) {
      return Error(closeResult.tryGetError()!);
    }

    // 2. Recreate at the same order, reusing validation in CreateBudgetUseCase.
    return _createBudgetUseCase.call(
      CreateBudgetParams(
        categoryId: newData.categoryId,
        name: newData.name,
        limit: newData.limit,
        startDate: newData.startDate,
        endDate: newData.endDate,
        order: old.order,
      ),
    );
  }
}
