import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/liability_entity.dart';
import '../repositories/liability_repository.dart';

/// Deletes a liability together with the debt transactions that belong to it.
///
/// A liability's balance is derived from its transactions (see
/// `GetLiabilityBalancesUseCase`), and any debt transaction without a matching
/// liability record is rebuilt into a synthetic liability. Removing only the
/// record would therefore make the same liability reappear, so its borrow /
/// repay (or lend / collect) transactions are soft-deleted first — which also
/// reverts their effect on wallet balances.
@lazySingleton
class DeleteLiabilityUseCase {
  DeleteLiabilityUseCase(this._liabilityRepository, this._transactionRepository);

  final LiabilityRepository _liabilityRepository;
  final TransactionRepository _transactionRepository;

  /// [target] is the liability as listed (its id may belong to a synthetic
  /// liability that has transactions but no stored record).
  Future<Result<void, CcFailure>> call(LiabilityEntity target) async {
    final liabilitiesResult = await _liabilityRepository.getLiabilities();
    if (liabilitiesResult.isError()) {
      return Error(liabilitiesResult.tryGetError()!);
    }
    final transactionsResult = await _transactionRepository
        .getListTransactions();
    if (transactionsResult.isError()) {
      return Error(transactionsResult.tryGetError()!);
    }

    final liabilities = liabilitiesResult.tryGetSuccess()!;
    final transactions = transactionsResult.tryGetSuccess()!;

    // The repository removes every record of the same direction and loan type
    // as the target, so those are the ids this deletion covers.
    final stored = liabilities.where((l) => l.id == target.id).firstOrNull;
    final groupIds = <String>{target.id};
    if (stored != null) {
      groupIds.addAll(
        liabilities
            .where(
              (l) =>
                  l.direction == stored.direction &&
                  (l.categoryId == stored.categoryId ||
                      _norm(l.categoryLabel) == _norm(stored.categoryLabel)),
            )
            .map((l) => l.id),
      );
    }
    final otherIds = liabilities
        .map((l) => l.id)
        .where((id) => !groupIds.contains(id))
        .toSet();

    final label = _norm(target.categoryLabel);
    final isBorrow = target.isBorrow;
    final transactionIds = transactions
        .where((t) {
          if (!t.isDebtActivity || t.isDeleted) return false;
          final matchesDirection = isBorrow
              ? t.type == TransactionType.debtBorrow ||
                    t.type == TransactionType.debtRepay
              : t.type == TransactionType.debtLend ||
                    t.type == TransactionType.debtCollect;
          if (!matchesDirection) return false;

          final liabilityId = t.liabilityId;
          if (liabilityId != null && liabilityId.isNotEmpty) {
            if (groupIds.contains(liabilityId)) return true;
            // Belongs to another stored liability, even if the label matches.
            if (otherIds.contains(liabilityId)) return false;
          }
          return _norm(t.category) == label;
        })
        .map((t) => t.id)
        .toList();

    if (transactionIds.isNotEmpty) {
      final softDeleted = await _transactionRepository.softDeleteByIds(
        transactionIds,
      );
      if (softDeleted.isError()) return softDeleted;
    }

    return _liabilityRepository.deleteLiability(target.id);
  }

  String _norm(String value) => value.trim().toLowerCase();
}
