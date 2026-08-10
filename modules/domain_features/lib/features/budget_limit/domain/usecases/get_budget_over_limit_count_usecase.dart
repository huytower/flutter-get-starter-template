import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/budget_over_limit_entity.dart';
import '../repositories/budget_limit_repository.dart';

/// Computes how many times a category's budget has been exceeded so far this
/// month — a pure derivation from transaction history (mirrors
/// [GetBudgetLimitStatsUseCase]'s "no persisted counter" convention).
///
/// A transaction counts as "one time over" when its position in the running
/// cumulative total (transactions sorted by date ascending) pushes the sum
/// past the budget's limit.
@lazySingleton
class GetBudgetOverLimitCountUseCase {
  GetBudgetOverLimitCountUseCase(
    this._budgetLimitRepository,
    this._transactionRepository,
  );

  final BudgetLimitRepository _budgetLimitRepository;
  final TransactionRepository _transactionRepository;

  Future<Result<BudgetOverLimitEntity?, CcFailure>> call(
    String categoryId,
  ) async {
    final budgetsResult = await _budgetLimitRepository.getBudgets(
      activeOnly: true,
    );
    if (budgetsResult.isError()) return Error(budgetsResult.tryGetError()!);

    final budgets = budgetsResult.tryGetSuccess()!;
    final budgetIdx = budgets.indexWhere((b) => b.categoryId == categoryId);
    if (budgetIdx < 0) return const Success(null);
    final budget = budgets[budgetIdx];

    final txnResult = await _transactionRepository.getListTransactions();
    if (txnResult.isError()) return Error(txnResult.tryGetError()!);

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final monthTxns =
        txnResult
            .tryGetSuccess()!
            .where(
              (t) =>
                  t.type == TransactionType.expense &&
                  t.categoryId == categoryId &&
                  !t.date.isBefore(monthStart) &&
                  t.date.isBefore(nextMonthStart),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    var running = 0;
    var count = 0;
    for (final t in monthTxns) {
      final before = running;
      running += t.amount;
      if (before <= budget.limit && running > budget.limit) count++;
    }

    if (count == 0) return const Success(null);
    return Success(BudgetOverLimitEntity(budgetName: budget.name, count: count));
  }
}
