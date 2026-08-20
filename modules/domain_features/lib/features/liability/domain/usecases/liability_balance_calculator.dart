import '../../../transaction/domain/entities/transaction_entity.dart';

/// Outstanding balance = principal − Σ repay/collect legs linked to the loan.
///
/// Mirrors `bookBalanceFromTransactions` (wallet feature): a pure reduction
/// over the loan's linked transactions, with no I/O or Hive/repository
/// dependency, so it can also back a future outstanding-debt report use case.
int loanOutstandingBalance(
  int principalAmount,
  List<TransactionEntity> loanTransactions,
) {
  var balance = principalAmount;
  for (final txn in loanTransactions) {
    // The initial leg (creation) is already reflected in [principalAmount].
    if (txn.id == '${txn.loanId}_init') continue;

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
