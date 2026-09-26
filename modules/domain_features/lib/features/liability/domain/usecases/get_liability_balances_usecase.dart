import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/di/di.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/liability_balance_entity.dart';
import '../entities/liability_entity.dart';
import '../repositories/liability_repository.dart';
import 'liability_balance_calculator.dart';

/// Computes the outstanding balance for every loan — backs the Settle-mode
/// outstanding-loans picker and (later) an outstanding-debt report.
@lazySingleton
class GetLiabilityBalancesUseCase {
  GetLiabilityBalancesUseCase(
    this._LiabilityRepository,
    this._transactionRepository,
  ) : _categoryRepository = getIt<CategoryRepository>();

  final LiabilityRepository _LiabilityRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  Future<Result<List<LiabilityBalanceEntity>, CcFailure>> call() async {
    final liabilitiesResult = await _LiabilityRepository.getLiabilities();
    if (liabilitiesResult.isError()) {
      return Error(liabilitiesResult.tryGetError()!);
    }

    final txnResult = await _transactionRepository.getListTransactions();
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }

    final catResult = await _categoryRepository.getCategories();
    final categories = catResult.tryGetSuccess() ?? <CategoryEntity>[];

    final rawLiabilities = liabilitiesResult.tryGetSuccess()!;
    final transactions = txnResult.tryGetSuccess()!;

    // Group liabilities by direction + categoryLabel (unique liability name)
    final grouped = <String, List<LiabilityEntity>>{};
    for (final l in rawLiabilities) {
      final labelKey = l.categoryLabel.trim().toLowerCase();
      final key = '${l.direction}_$labelKey';
      grouped.putIfAbsent(key, () => <LiabilityEntity>[]).add(l);
    }

    final balances = <LiabilityBalanceEntity>[];

    for (final entry in grouped.entries) {
      final List<LiabilityEntity> items = entry.value;
      // Primary liability entity (most recently updated)
      items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final primary = items.first;

      // Collect all liability IDs belonging to this group
      final groupIds = items.map((e) => e.id).toSet();

      // Collect all transactions belonging to any liability in this group
      final groupTxns = transactions
          .where((t) => groupIds.contains(t.liabilityId))
          .toList();

      // Total principal amount across all liabilities in this group
      final totalPrincipal = items.fold<int>(
        0,
        (sum, item) => sum + item.principalAmount,
      );

      final cat = categories.firstWhereOrNull(
        (c) => c.id == primary.categoryId,
      );

      final combinedEntity = primary.copyWith(
        principalAmount: totalPrincipal,
        categoryNameKey: cat?.nameKey,
      );

      final balance = LiabilityBalanceEntity(
        liability: combinedEntity,
        outstandingBalance: liabilityOutstandingBalance(
          totalPrincipal,
          groupTxns,
        ),
      );

      balances.add(balance);
    }

    balances.sort(
      (a, b) => b.liability.updatedAt.compareTo(a.liability.updatedAt),
    );

    return Success(balances);
  }
}
