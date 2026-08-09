import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/trend_data_entity.dart';
import '../report_range.dart';
import 'trend_bucketer.dart';

@lazySingleton
class GetTrendDataUseCase {
  GetTrendDataUseCase(this._transactionRepository, this._categoryRepository);

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  Future<Result<TrendDataEntity, CcFailure>> call({
    required ReportRange range,
    int offset = 0, // Used for navigation in Monthly/Yearly
    String? walletId,
  }) async {
    final window = trendWindowFor(range, offset);

    final txnResult = await _transactionRepository.getTransactionsByPeriod(
      window.start,
      window.end,
    );
    if (txnResult.isError()) return Error(txnResult.tryGetError()!);

    final catResult = await _categoryRepository.getCategories();
    final Map<String, CategoryEntity> catMap = catResult.isSuccess()
        ? {for (var c in catResult.tryGetSuccess()!) c.id: c}
        : {};

    // Filter out transfers, investment activity, debt activity, and deleted
    // transactions, and map icons
    final allTransactions = txnResult
        .tryGetSuccess()!
        .where(
          (t) =>
              !t.isTransfer &&
              !t.isInvestmentActivity &&
              !t.isDebtActivity &&
              !t.isDeleted &&
              (walletId == null || t.walletId == walletId),
        )
        .map((t) {
          final cat = catMap[t.categoryId];
          return t.copyWith(
            categoryIconCode: cat?.iconCode,
            categoryIconFamily: cat?.iconFamily,
          );
        })
        .toList();

    final points = bucketTrendPoints(
      transactions: allTransactions,
      range: range,
      window: window,
      inflowAmount: (t) =>
          t.type == TransactionType.income ? t.amount.toDouble() : 0,
      outflowAmount: (t) =>
          t.type == TransactionType.expense ? t.amount.toDouble() : 0,
    );

    final totalIncome = allTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = allTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Success(
      TrendDataEntity(
        points: points,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        transactions: allTransactions..sort((a, b) => b.date.compareTo(a.date)),
      ),
    );
  }
}
