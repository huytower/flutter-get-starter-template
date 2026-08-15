import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/helper/spend_anomaly_helper.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import 'get_budget_limit_stats_usecase.dart';

class BudgetAnomalyEntity extends Equatable {
  final String budgetName;
  final int thisMonthSpend;
  final double avgPrevMonths;

  const BudgetAnomalyEntity({
    required this.budgetName,
    required this.thisMonthSpend,
    required this.avgPrevMonths,
  });

  @override
  List<Object?> get props => [budgetName, thisMonthSpend, avgPrevMonths];
}

/// Phase 3.4 "AI Actions for Budget Issues" — flags budgets whose spend this
/// month is a sudden spike vs the preceding 3 months' average for that same
/// category (see [isAnomalousSpend]). Pure local computation, no LLM call —
/// "suggest income increase strategies" (the one genuinely LLM-shaped action
/// in the spec) is deliberately out of scope here, deferred to a later
/// phase.
@lazySingleton
class GetBudgetAnomaliesUseCase {
  GetBudgetAnomaliesUseCase(this._getBudgetStats, this._transactionRepository);

  final GetBudgetLimitStatsUseCase _getBudgetStats;
  final TransactionRepository _transactionRepository;

  Future<Result<List<BudgetAnomalyEntity>, CcFailure>> call() async {
    final statsResult = await _getBudgetStats.call();
    if (statsResult.isError()) return Error(statsResult.tryGetError()!);
    final stats = statsResult.tryGetSuccess()!;
    if (stats.isEmpty) return const Success([]);

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final start3MonthsAgo = DateTime(now.year, now.month - 3, 1);

    final txnResult = await _transactionRepository.getTransactionsByPeriod(
      start3MonthsAgo,
      now,
    );
    if (txnResult.isError()) return Error(txnResult.tryGetError()!);

    final prevExpenses = txnResult
        .tryGetSuccess()!
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isBefore(startOfMonth),
        );

    final anomalies = <BudgetAnomalyEntity>[];
    for (final stat in stats) {
      final categoryPrevExpenses = prevExpenses
          .where((t) => t.categoryId == stat.budget.categoryId)
          .toList();
      final avgPrev = _averageMonthlySpend(categoryPrevExpenses, startOfMonth);

      if (isAnomalousSpend(stat.spent, avgPrev)) {
        anomalies.add(
          BudgetAnomalyEntity(
            budgetName: stat.budget.name,
            thisMonthSpend: stat.spent,
            avgPrevMonths: avgPrev,
          ),
        );
      }
    }
    return Success(anomalies);
  }

  /// Averages [expenses] over however many of the preceding 3 calendar
  /// months actually contain data for this category, not a flat 3 — a
  /// category with e.g. only 1 of the last 3 months populated would
  /// otherwise get an artificially deflated baseline (total / 3 instead of
  /// total / 1), causing normal spend to be flagged as a false "spike".
  /// Same clamping idea as [GetCategoryAverageMonthlySpendUseCase]'s
  /// average, computed independently here since that use case's window
  /// includes the current partial month while this one deliberately
  /// excludes it (see [prevExpenses] above).
  double _averageMonthlySpend(
    List<TransactionEntity> expenses,
    DateTime startOfMonth,
  ) {
    if (expenses.isEmpty) return 0;
    final total = expenses.fold<int>(0, (sum, t) => sum + t.amount);
    final earliest = expenses
        .map((t) => t.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final monthsOfData =
        ((startOfMonth.year - earliest.year) * 12 +
                (startOfMonth.month - earliest.month))
            .clamp(1, 3);
    return total / monthsOfData;
  }
}
