import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class CreateBudgetParams {
  final String categoryId;
  final String name;
  final int limit;
  final DateTime startDate;
  final DateTime endDate;

  /// Optional explicit order; when null the next order is computed.
  final int? order;

  const CreateBudgetParams({
    required this.categoryId,
    required this.name,
    required this.limit,
    required this.startDate,
    required this.endDate,
    this.order,
  });
}

/// Creates a budget after validating input (mirrors `CreateNganSachUseCase`).
@lazySingleton
class CreateBudgetUseCase {
  CreateBudgetUseCase(this._repository);

  final BudgetRepository _repository;

  Future<Result<BudgetEntity, CcFailure>> call(CreateBudgetParams params) async {
    final name = params.name.trim();
    if (name.isEmpty) {
      return const Error(ValidationFailure('Tên ngân sách không được để trống!'));
    }
    if (params.categoryId.isEmpty) {
      return const Error(ValidationFailure('Vui lòng chọn hạng mục!'));
    }
    if (params.limit <= 0) {
      return const Error(ValidationFailure('Định mức ngân sách phải lớn hơn 0!'));
    }
    if (!params.endDate.isAfter(params.startDate)) {
      return const Error(
        ValidationFailure('Thời gian kết thúc phải sau thời gian bắt đầu!'),
      );
    }

    var order = params.order;
    if (order == null) {
      final existing = await _repository.getBudgets(activeOnly: false);
      if (existing.isError()) {
        return Error(existing.tryGetError()!);
      }
      final budgets = existing.tryGetSuccess()!;
      order = budgets.isEmpty
          ? 0
          : budgets.map((b) => b.order).reduce((a, b) => a > b ? a : b) + 1;
    }

    final budget = BudgetEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      categoryId: params.categoryId,
      name: name,
      limit: params.limit,
      startDate: params.startDate,
      endDate: params.endDate,
      order: order,
    );

    final result = await _repository.createBudget(budget);
    if (result.isError()) {
      return Error(result.tryGetError()!);
    }
    return Success(budget);
  }
}
