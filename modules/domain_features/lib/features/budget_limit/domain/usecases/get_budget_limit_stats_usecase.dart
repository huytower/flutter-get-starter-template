import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/budget_limit_stats_entity.dart';
import '../repositories/budget_limit_repository.dart';

/// Computes spending per active budget and joins the linked category's icon/colour.
///
/// Replaces the web `sum_thong_ke_ngan_sach` view — spent = Σ expense
/// transactions in the budget's category within the CURRENT calendar month.
@lazySingleton
class GetBudgetLimitStatsUseCase {
  GetBudgetLimitStatsUseCase(
    this._budgetLimitRepository,
    this._transactionRepository,
    this._categoryRepository,
  );

  final BudgetLimitRepository _budgetLimitRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  Future<Result<List<BudgetLimitStatsEntity>, CcFailure>> call() async {
    final budgetsResult = await _budgetLimitRepository.getBudgets(
      activeOnly: true,
    );
    if (budgetsResult.isError()) return Error(budgetsResult.tryGetError()!);

    final txnResult = await _transactionRepository.getListTransactions();
    if (txnResult.isError()) return Error(txnResult.tryGetError()!);

    final catResult = await _categoryRepository.getCategories();
    final categories = catResult.tryGetSuccess() ?? <CategoryEntity>[];

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);

    final transactions = txnResult.tryGetSuccess()!;
    final stats = budgetsResult.tryGetSuccess()!.map((budget) {
      final spent = transactions
          .where(
            (t) =>
                t.type == 'expense' &&
                t.categoryId == budget.categoryId &&
                !t.date.isBefore(monthStart) &&
                t.date.isBefore(nextMonthStart),
          )
          .fold<int>(0, (sum, t) => sum + t.amount);

      final catIdx = categories.indexWhere((c) => c.id == budget.categoryId);
      final cat = catIdx >= 0 ? categories[catIdx] : null;

      return BudgetLimitStatsEntity(
        budget: budget,
        spent: spent,
        iconCode: cat?.iconCode ?? 0,
        iconFamily: cat?.iconFamily,
        color: cat?.color,
        categoryNameKey: cat?.nameKey,
      );
    }).toList();

    return Success(stats);
  }
}
