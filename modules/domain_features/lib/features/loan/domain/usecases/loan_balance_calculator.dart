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
    switch (txn.type) {
      case TransactionType.debtRepay:
      case TransactionType.debtCollect:
        balance -= txn.amount;
        break;
    }
  }
  return balance;
}
