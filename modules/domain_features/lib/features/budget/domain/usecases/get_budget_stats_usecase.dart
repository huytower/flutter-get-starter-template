import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/budget_stats_entity.dart';
import '../repositories/budget_repository.dart';

/// Computes spending per active budget (replaces the web
/// `sum_thong_ke_ngan_sach` view): spent = Σ expense transactions in the
/// budget's category within its period.
///
/// Matching is by category + period rather than a transaction's stored
/// [budgetId], so an expense counts regardless of whether it was entered
/// before or after the budget existed.
@lazySingleton
class GetBudgetStatsUseCase {
  GetBudgetStatsUseCase(this._budgetRepository, this._transactionRepository);

  final BudgetRepository _budgetRepository;
  final TransactionRepository _transactionRepository;

  Future<Result<List<BudgetStatsEntity>, CcFailure>> call() async {
    final budgetsResult = await _budgetRepository.getBudgets(activeOnly: true);
    if (budgetsResult.isError()) {
      return Error(budgetsResult.tryGetError()!);
    }

    final txnResult = await _transactionRepository.getListTransactions();
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final transactions = txnResult.tryGetSuccess()!;
    final stats = budgetsResult.tryGetSuccess()!.map((budget) {
      final spent = transactions
          .where(
            (t) =>
                t.type == 'expense' &&
                t.categoryId == budget.categoryId &&
                budget.containsDate(t.date),
          )
          .fold<int>(0, (sum, t) => sum + t.amount);
      return BudgetStatsEntity(budget: budget, spent: spent);
    }).toList();

    return Success(stats);
  }
}
