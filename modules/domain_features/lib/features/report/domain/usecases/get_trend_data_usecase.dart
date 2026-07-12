import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/trend_data_entity.dart';
import '../report_range.dart';

@lazySingleton
class GetTrendDataUseCase {
  GetTrendDataUseCase(this._transactionRepository, this._categoryRepository);

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  Future<Result<TrendDataEntity, CcFailure>> call({
    required ReportRange range,
    int offset = 0, // Used for navigation in Monthly/Yearly
  }) async {
    final now = DateTime.now();
    DateTime start;
    DateTime end;
    int pointsCount;

    switch (range) {
      case ReportRange.weekly:
        // Tab "Tháng": Always 4 weeks near most, no navigation.
        pointsCount = 4;
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        start = DateTime(now.year, now.month, now.day - 27, 0, 0, 0, 0);
        break;
      case ReportRange.monthly:
        // Tab "3 Tháng": 3 months increments.
        pointsCount = 3;
        final refMonth = now.month - (offset * 3);
        end = DateTime(now.year, refMonth + 1, 0, 23, 59, 59, 999);
        start = DateTime(now.year, refMonth - 2, 1);
        break;
      case ReportRange.yearly:
        // Tab "Năm": 12 months increments.
        pointsCount = 12;
        final refMonth = now.month - (offset * 12);
        end = DateTime(now.year, refMonth + 1, 0, 23, 59, 59, 999);
        start = DateTime(now.year, refMonth - 11, 1);
        break;
    }

    final txnResult = await _transactionRepository.getTransactionsByPeriod(start, end);
    if (txnResult.isError()) return Error(txnResult.tryGetError()!);

    final catResult = await _categoryRepository.getCategories();
    final Map<String, CategoryEntity> catMap = catResult.isSuccess()
        ? {for (var c in catResult.tryGetSuccess()!) c.id: c}
        : {};

    // Filter out transfers and deleted transactions, and map icons
    final allTransactions = txnResult
        .tryGetSuccess()!
        .where((t) => !t.isTransfer && !t.isDeleted)
        .map((t) {
          final cat = catMap[t.categoryId];
          return t.copyWith(
            categoryIconCode: cat?.iconCode,
            categoryIconFamily: cat?.iconFamily,
          );
        })
        .toList();

    final points = <TrendPoint>[];
    double totalIncome = 0;
    double totalExpense = 0;

    if (range == ReportRange.weekly) {
      // Group by 7-day periods
      for (int i = 0; i < 4; i++) {
        final pStart = start.add(Duration(days: i * 7));
        final pEnd = pStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        
        final periodTxns = allTransactions.where((t) => 
          t.date.isAfter(pStart.subtract(const Duration(seconds: 1))) && 
          t.date.isBefore(pEnd.add(const Duration(seconds: 1)))
        ).toList();
        
        final income = periodTxns
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final expense = periodTxns
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (sum, t) => sum + t.amount);
        
        totalIncome += income;
        totalExpense += expense;

        points.add(TrendPoint(
          label: "Tuần ${i + 1}",
          income: income,
          expense: expense,
          date: pStart,
        ));
      }
    } else {
      // Group by month
      for (int i = 0; i < pointsCount; i++) {
        final mDate = DateTime(start.year, start.month + i, 1);
        final mEnd = DateTime(start.year, start.month + i + 1, 0, 23, 59, 59, 999);
        
        final periodTxns = allTransactions.where((t) => 
          t.date.isAfter(mDate.subtract(const Duration(seconds: 1))) && 
          t.date.isBefore(mEnd.add(const Duration(seconds: 1)))
        ).toList();
        
        final income = periodTxns
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final expense = periodTxns
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (sum, t) => sum + t.amount);
        
        totalIncome += income;
        totalExpense += expense;

        String label;
        if (range == ReportRange.monthly) {
          label = DateFormat('M/yy').format(mDate);
        } else {
          // Yearly: Quarterly labels (Aug/25, Nov/25, Feb/26, May/26)
          // We show all 12 points, but labels might be sparse in UI. 
          // Here we provide the full label, UI can decide to skip.
          label = DateFormat('M/yy').format(mDate);
        }

        points.add(TrendPoint(
          label: label,
          income: income,
          expense: expense,
          date: mDate,
        ));
      }
    }

    return Success(TrendDataEntity(
      points: points,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      transactions: allTransactions..sort((a, b) => b.date.compareTo(a.date)),
    ));
  }
}
