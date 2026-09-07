import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/trend_data_entity.dart';
import '../report_range.dart';
import 'trend_bucketer.dart';

/// Investment "chart" for the report page — Chi ra (capital contributed,
/// [TransactionType.investmentOut]) vs Thu vào (returns,
/// [TransactionType.investmentReturn]), reusing [TrendCard]'s
/// income/expense-shaped rendering (return→income slot, contributed→expense
/// slot). [TransactionType.investmentIn] is excluded — it's the mirror leg
/// of [investmentOut] on the investment wallet itself, summing both would
/// double-count the same capital movement.
///
/// [walletId] matches against either [TransactionEntity.walletId] (the real
/// wallet the money moved through — a liquid wallet for both legs now) or
/// [TransactionEntity.investmentWalletId] (the position itself), so this
/// still works whether the caller is reviewing a liquid wallet's activity or
/// (in a future per-item view) a specific investment position's.
@lazySingleton
class GetInvestmentTrendUseCase {
  GetInvestmentTrendUseCase(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Future<Result<TrendDataEntity, CcFailure>> call({
    required ReportRange range,
    int offset = 0,
    String? walletId,
  }) async {
    final window = trendWindowFor(range, offset);

    final txnResult = await _transactionRepository.getTransactionsByPeriod(
      window.start,
      window.end,
    );
    if (txnResult.isError()) return Error(txnResult.tryGetError()!);

    final transactions = txnResult
        .tryGetSuccess()!
        .where(
          (t) =>
              !t.isDeleted &&
              (t.type == TransactionType.investmentOut ||
                  t.type == TransactionType.investmentReturn) &&
              (walletId == null ||
                  t.walletId == walletId ||
                  t.investmentWalletId == walletId),
        )
        .toList();

    final points = bucketTrendPoints(
      transactions: transactions,
      range: range,
      window: window,
      inflowAmount: (t) =>
          t.type == TransactionType.investmentReturn ? t.amount.toDouble() : 0,
      outflowAmount: (t) =>
          t.type == TransactionType.investmentOut ? t.amount.toDouble() : 0,
    );

    final totalReturned = transactions
        .where((t) => t.type == TransactionType.investmentReturn)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalContributed = transactions
        .where((t) => t.type == TransactionType.investmentOut)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final sortedTransactions = transactions.toList();
    sortedTransactions.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;

      final idA = double.tryParse(a.id) ?? 0;
      final idB = double.tryParse(b.id) ?? 0;
      return idB.compareTo(idA);
    });

    return Success(
      TrendDataEntity(
        points: points,
        totalIncome: totalReturned,
        totalExpense: totalContributed,
        transactions: sortedTransactions,
      ),
    );
  }
}
