import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/category_spending_entity.dart';

@lazySingleton
class GetCategorySpendingUseCase {
  GetCategorySpendingUseCase(
    this._transactionRepository,
    this._categoryRepository,
    this._conversionService,
  );

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final CurrencyConversionService _conversionService;

  Future<Result<List<CategorySpendingEntity>, CcFailure>> call({
    required DateTime start,
    required DateTime end,
    String? walletId,
    required String targetCurrency,
  }) async {
    final txnResult = await _transactionRepository.getTransactionsByPeriod(
      start,
      end,
    );
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final catResult = await _categoryRepository.getCategories();
    if (catResult.isError()) {
      return Error(catResult.tryGetError()!);
    }

    final categories = <String, CategoryEntity>{
      for (final c in catResult.tryGetSuccess()!) c.id: c,
    };

    final totals = <String, Map<String, int>>{};
    for (final t in txnResult.tryGetSuccess()!) {
      if (t.type != 'expense') continue;
      if (walletId != null && t.walletId != walletId) continue;
      totals
          .putIfAbsent(t.categoryId, () => <String, int>{})
          .update(
            t.currencyCode,
            (value) => value + t.amount,
            ifAbsent: () => t.amount,
          );
    }

    final convertedTotals = <String, int>{};
    for (final entry in totals.entries) {
      final result = await _conversionService.convertTotal(
        amountsByCurrency: entry.value,
        targetCurrency: targetCurrency,
      );
      convertedTotals[entry.key] =
          result.tryGetSuccess() ??
          entry.value.values.fold<int>(0, (sum, amount) => sum + amount);
    }

    final grandTotal = convertedTotals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    if (grandTotal <= 0) {
      return const Success(<CategorySpendingEntity>[]);
    }

    final slices = convertedTotals.entries.map((entry) {
      final category = categories[entry.key];
      return CategorySpendingEntity(
        categoryId: entry.key,
        nameKey: category?.nameKey ?? CcLocaleKeys.report_uncategorized,
        iconCode: category?.iconCode ?? 0xe148,
        iconFamily: category?.iconFamily,
        color: category?.color,
        amount: entry.value,
        fraction: entry.value / grandTotal,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
    return Success(slices);
  }
}
