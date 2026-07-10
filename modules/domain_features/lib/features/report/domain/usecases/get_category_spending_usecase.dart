import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/category_spending_entity.dart';

/// Spend-by-category breakdown for the pie chart ("tỷ trọng chi tiêu").
///
/// Groups expense transactions in `[start, end]` by their `categoryId`, joins
/// each group to its [CategoryEntity] for the label/icon/colour, and returns
/// slices sorted by amount descending with each slice's share of the total.
/// Replaces the web's server-side aggregation.
@lazySingleton
class GetCategorySpendingUseCase {
  GetCategorySpendingUseCase(
    this._transactionRepository,
    this._categoryRepository,
  );

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  /// Fallback label for expenses whose category was deleted or never set.
  static const String _uncategorizedKey = 'Chưa phân loại';

  Future<Result<List<CategorySpendingEntity>, CcFailure>> call({
    required DateTime start,
    required DateTime end,
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

    // Sum expenses per category.
    final totals = <String, int>{};
    for (final t in txnResult.tryGetSuccess()!) {
      if (t.type != 'expense') continue;
      totals.update(
        t.categoryId,
        (value) => value + t.amount,
        ifAbsent: () => t.amount,
      );
    }

    final grandTotal = totals.values.fold<double>(0, (sum, v) => sum + v);
    if (grandTotal <= 0) {
      return const Success(<CategorySpendingEntity>[]);
    }

    final slices = totals.entries.map((entry) {
      final category = categories[entry.key];
      return CategorySpendingEntity(
        categoryId: entry.key,
        nameKey: category?.nameKey ?? _uncategorizedKey,
        iconCode: category?.iconCode ?? 0xe148, // Icons.help_outline
        iconFamily: category?.iconFamily,
        color: category?.color,
        amount: entry.value,
        fraction: entry.value / grandTotal,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    return Success(slices);
  }
}
