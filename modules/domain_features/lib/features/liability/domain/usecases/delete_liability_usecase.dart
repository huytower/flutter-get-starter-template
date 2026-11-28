import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/domain/services/reconciled_period_lock.dart';
import '../repositories/liability_repository.dart';

/// Deletes a liability together with the debt transactions in the open period that
/// belong to it.
///
/// Transactions in a reconciled period ([ReconciledPeriodLock]) are preserved
/// (not deleted) to protect closed historical balances.
@lazySingleton
class DeleteLiabilityUseCase {
  DeleteLiabilityUseCase(
    this._liabilityRepository,
    this._transactionRepository,
    this._periodLock,
  );

  final LiabilityRepository _liabilityRepository;
  final TransactionRepository _transactionRepository;
  final ReconciledPeriodLock _periodLock;

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

    final lockedUntil = await _periodLock.lockedUntil();
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
    final hasBorrow = target.hasBorrow;
    final openTransactionIds = transactions
        .where((t) {
          if (!t.hasDebtActivity || t.hasDeleted) return false;
          if (ReconciledPeriodLock.hasLocked(t, lockedUntil)) return false;

          final matchesDirection = hasBorrow
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

    if (openTransactionIds.isNotEmpty) {
      final softDeleted = await _transactionRepository.softDeleteByIds(
        openTransactionIds,
      );
      if (softDeleted.isError()) return softDeleted;
    }

    return _liabilityRepository.deleteLiability(target.id);
  }

  String _norm(String value) => value.trim().toLowerCase();
}
