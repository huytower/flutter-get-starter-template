import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/budget_repository.dart';

/// Updates only a budget's limit (mirrors `UpdateDinhMucNganSachUseCase`).
@lazySingleton
class UpdateBudgetLimitUseCase {
  UpdateBudgetLimitUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Result<void, CcFailure>> call(String id, int newLimit) async {
    if (newLimit < 0) {
      return const Error(ValidationFailure('Định mức không được âm.'));
    }

    final budgetResult = await _repository.getBudget(id);
    if (budgetResult.isError()) {
      return Error(budgetResult.tryGetError()!);
    }

    return _repository.updateBudget(
      budgetResult.tryGetSuccess()!.copyWith(limit: newLimit),
    );
  }
}
