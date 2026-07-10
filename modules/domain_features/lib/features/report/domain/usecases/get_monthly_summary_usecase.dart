import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/monthly_summary_entity.dart';

/// Income-vs-expense totals for the last [months] calendar months (oldest →
/// newest), for the trend bar chart.
///
/// Months with no activity are still returned (as zeros) so the axis stays
/// continuous.
@lazySingleton
class GetMonthlySummaryUseCase {
  GetMonthlySummaryUseCase(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Future<Result<List<MonthlySummaryEntity>, CcFailure>> call({
    int months = 6,
    DateTime? reference,
  }) async {
    final now = reference ?? DateTime.now();
    final rangeStart = DateTime(now.year, now.month - (months - 1), 1);
    final rangeEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final txnResult = await _transactionRepository.getTransactionsByPeriod(
      rangeStart,
      rangeEnd,
    );
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    // Seed every month in the window with zeros so gaps still render.
    final income = <String, int>{};
    final expense = <String, int>{};
    final ordered = <MonthlySummaryEntity Function()>[];
    for (var i = 0; i < months; i++) {
      final m = DateTime(now.year, now.month - (months - 1) + i, 1);
      final key = '${m.year}-${m.month}';
      income[key] = 0;
      expense[key] = 0;
      ordered.add(
        () => MonthlySummaryEntity(
          year: m.year,
          month: m.month,
          income: income[key]!,
          expense: expense[key]!,
        ),
      );
    }

    for (final t in txnResult.tryGetSuccess()!) {
      final key = '${t.date.year}-${t.date.month}';
      if (!income.containsKey(key)) continue;
      if (t.type == 'income') {
        income[key] = income[key]! + t.amount;
      } else if (t.type == 'expense') {
        expense[key] = expense[key]! + t.amount;
      }
    }

    return Success(ordered.map((build) => build()).toList());
  }
}
