import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';

/// Phase 3.4 "Smart Budget Setup" (see `docs/BUSINESS_REQUIREMENT.md`):
/// average of the last 3 months' actual expense in [categoryId], for
/// suggesting a new budget's limit. Averages over however many of the last 3
/// calendar months actually have data (same clamping idea as
/// `GetFinancialRunwayUseCase`'s runway average, computed independently here
/// to avoid coupling this budget-specific estimate to that unrelated
/// feature) — a single month of history isn't divided by 3.
@lazySingleton
class GetCategoryAverageMonthlySpendUseCase {
  GetCategoryAverageMonthlySpendUseCase(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  Future<Result<int, CcFailure>> call(String categoryId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 3, 1);

    final result = await _transactionRepository.getTransactionsByPeriod(
      start,
      now,
    );
    if (result.isError()) return Error(result.tryGetError()!);

    final relevant = result
        .tryGetSuccess()!
        .where(
          (t) => t.type == TransactionType.expense && t.categoryId == categoryId,
        )
        .toList();
    if (relevant.isEmpty) return const Success(0);

    final total = relevant.fold<int>(0, (sum, t) => sum + t.amount);
    final earliest = relevant
        .map((t) => t.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final monthsOfData =
        ((now.year - earliest.year) * 12 + (now.month - earliest.month) + 1)
            .clamp(1, 3);

    return Success((total / monthsOfData).round());
  }
}
