import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/budget_limit_repository.dart';

/// Edits an existing budget (mirrors `UpdateDinhMucNganSachUseCase`).
///
/// The name may change at any time; the limit may only change during the
/// first week of a month (days 1–7), so a running month's cap can't be moved
/// mid-month. Pass null to leave a field unchanged.
@lazySingleton
class UpdateBudgetLimitUseCase {
  UpdateBudgetLimitUseCase(this._repository);

  /// Last day of the month on which the limit may still be changed.
  static const int lastEditableDay = 7;

  /// Whether today falls inside the limit-editing window.
  static bool get isLimitEditable => DateTime.now().day <= lastEditableDay;

  final BudgetLimitRepository _repository;

  Future<Result<void, CcFailure>> call(
    String id, {
    String? name,
    int? limit,
  }) async {
    final budgetResult = await _repository.getBudget(id);
    if (budgetResult.isError()) {
      return Error(budgetResult.tryGetError()!);
    }
    var budget = budgetResult.tryGetSuccess()!;

    if (name != null) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) {
        return const Error(
          ValidationFailure('Tên ngân sách không được để trống!'),
        );
      }
      budget = budget.copyWith(name: trimmed);
    }

    if (limit != null && limit != budget.limit) {
      if (!isLimitEditable) {
        return const Error(
          ValidationFailure(
            'Chỉ có thể thay đổi định mức trong 7 ngày đầu tháng.',
          ),
        );
      }
      if (limit <= 0) {
        return const Error(
          ValidationFailure('Định mức ngân sách phải lớn hơn 0!'),
        );
      }
      budget = budget.copyWith(limit: limit);
    }

    return _repository.updateBudget(budget);
  }
}
