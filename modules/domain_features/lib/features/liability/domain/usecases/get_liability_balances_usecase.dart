import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/di/di.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/liability_balance_entity.dart';
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

    final transactions = txnResult.tryGetSuccess()!;
    final unique = <String, LiabilityBalanceEntity>{};
    for (final liability in liabilitiesResult.tryGetSuccess()!) {
      final liabilityTxns = transactions
          .where((t) => t.liabilityId == liability.id)
          .toList();

      final cat = categories.firstWhereOrNull(
        (c) => c.id == liability.categoryId,
      );

      final balance = LiabilityBalanceEntity(
        liability: liability.copyWith(categoryNameKey: cat?.nameKey),
        outstandingBalance: liabilityOutstandingBalance(
          liability.principalAmount,
          liabilityTxns,
        ),
      );
      unique[liability.id] = balance;
    }
    final balances = unique.values.toList()
      ..sort((a, b) => b.liability.updatedAt.compareTo(a.liability.updatedAt));

    return Success(balances);
  }
}
