import '../../../transaction/domain/entities/transaction_entity.dart';

/// Outstanding balance = principal − Σ repay/collect legs linked to the liability.
///
/// Mirrors `bookBalanceFromTransactions` (wallet feature): a pure reduction
/// over the liability's linked transactions, with no I/O or Hive/repository
/// dependency, so it can also back a future outstanding-debt report use case.
int liabilityOutstandingBalance(
  int principalAmount,
  List<TransactionEntity> liabilityTransactions,
) {
  var balance = principalAmount;
  for (final txn in liabilityTransactions) {
    // The initial leg (creation) is already reflected in [principalAmount].
    if (txn.id == '${txn.liabilityId}_init') continue;

    switch (txn.type) {
      case TransactionType.debtBorrow:
      case TransactionType.debtLend:
        balance += txn.amount;
        break;
      case TransactionType.debtRepay:
      case TransactionType.debtCollect:
        balance -= txn.amount;
        break;
    }
  }
  return balance;
}
