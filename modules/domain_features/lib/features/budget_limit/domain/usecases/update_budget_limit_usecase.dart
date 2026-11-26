import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/budget_limit_lock_reason.dart';
import '../repositories/budget_limit_repository.dart';
import '../services/budget_limit_edit_policy.dart';

/// Edits an existing budget (mirrors `UpdateDinhMucNganSachUseCase`).
///
/// The name and the fixed-price flag may change at any time. The limit may
/// not change after day 7 of the month, nor once spending has been recorded
/// against the budget this month ([BudgetLimitEditPolicy]). Pass null to leave
/// a field unchanged.
@lazySingleton
class UpdateBudgetLimitUseCase {
  UpdateBudgetLimitUseCase(this._repository, this._editPolicy);

  final BudgetLimitRepository _repository;
  final BudgetLimitEditPolicy _editPolicy;

  Future<Result<void, CcFailure>> call(
    String id, {
    String? name,
    int? limit,
    bool? hasFixedPrice,
  }) async {
    final budgetResult = await _repository.getBudget(id);
    if (budgetResult.isError()) {
      return Error(budgetResult.tryGetError()!);
    }
    var budget = budgetResult.tryGetSuccess()!;

    if (hasFixedPrice != null) {
      budget = budget.copyWith(hasFixedPrice: hasFixedPrice);
    }

    if (name != null) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) {
        return const Error(
          CcValidationFailure('Tên ngân sách không được để trống!'),
        );
      }
      budget = budget.copyWith(name: trimmed);
    }

    if (limit != null && limit != budget.limit) {
      final lockReason = await _editPolicy.lockReasonFor(budget);
      if (lockReason != null) {
        return Error(CcValidationFailure(_lockMessageKey(lockReason)));
      }
      if (limit <= 0) {
        return const Error(
          CcValidationFailure('Định mức ngân sách phải lớn hơn 0!'),
        );
      }
      budget = budget.copyWith(limit: limit);
    }

    return _repository.updateBudget(budget);
  }

  /// Locale key explaining [reason]; the caller translates it.
  static String _lockMessageKey(BudgetLimitLockReason reason) =>
      switch (reason) {
        BudgetLimitLockReason.pastFirstWeek => PrjLocaleKeys.budget_limit_locked,
        BudgetLimitLockReason.hasSpending =>
          PrjLocaleKeys.budget_limit_locked_has_spending,
      };
}
