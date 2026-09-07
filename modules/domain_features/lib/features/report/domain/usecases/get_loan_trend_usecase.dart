import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/trend_data_entity.dart';
import '../report_range.dart';
import 'trend_bucketer.dart';

/// Liability/debt "chart" for the report page — cash in (Đi vay
/// [TransactionType.debtBorrow] + Thu nợ [TransactionType.debtCollect]) vs
/// cash out (Cho vay [TransactionType.debtLend] + Trả nợ
/// [TransactionType.debtRepay]), reusing [TrendCard]'s income/expense-shaped
/// rendering. Covers both directions (borrow and lend) as one combined cash
/// flow rather than splitting into four lines.
@lazySingleton
class GetLoanTrendUseCase {
  GetLoanTrendUseCase(this._transactionRepository);

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
              t.isDebtActivity &&
              (walletId == null || t.walletId == walletId),
        )
        .toList();

    bool isCashIn(TransactionEntity t) =>
        t.type == TransactionType.debtBorrow ||
        t.type == TransactionType.debtCollect;

    final points = bucketTrendPoints(
      transactions: transactions,
      range: range,
      window: window,
      inflowAmount: (t) => isCashIn(t) ? t.amount.toDouble() : 0,
      outflowAmount: (t) => !isCashIn(t) ? t.amount.toDouble() : 0,
    );

    final totalIn = transactions
        .where(isCashIn)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalOut = transactions
        .where((t) => !isCashIn(t))
        .fold<double>(0, (sum, t) => sum + t.amount);

    final sortedTransactions = transactions.toList();
    sortedTransactions.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;

      if (b.id.length != a.id.length) {
        return b.id.length.compareTo(a.id.length);
      }
      return b.id.compareTo(a.id);
    });

    return Success(
      TrendDataEntity(
        points: points,
        totalIncome: totalIn,
        totalExpense: totalOut,
        transactions: sortedTransactions,
      ),
    );
  }
}
