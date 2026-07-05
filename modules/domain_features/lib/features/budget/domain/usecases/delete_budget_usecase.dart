import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/budget_repository.dart';

@lazySingleton
class DeleteBudgetUseCase {
  DeleteBudgetUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Result<void, CcFailure>> call(String id) =>
      _repository.deleteBudget(id);
}
