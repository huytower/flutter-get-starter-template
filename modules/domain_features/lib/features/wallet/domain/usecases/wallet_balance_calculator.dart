import '../../../transaction/domain/entities/transaction_entity.dart';

/// Book balance = opening balance + Σ income − Σ expense (± transfer legs) for
/// the wallet.
///
/// `openingBalance` is [WalletEntity.balance] (the "số dư đầu kỳ" the user
/// enters when creating the wallet). A transfer contributes a `transferOut` leg
/// (money leaving this wallet) and a `transferIn` leg (money arriving), so the
/// two legs cancel out across the wallets involved.
int bookBalanceFromTransactions(
  int openingBalance,
  List<TransactionEntity> walletTransactions,
) {
  var balance = openingBalance;
  for (final txn in walletTransactions) {
    switch (txn.type) {
      case TransactionType.income:
      case TransactionType.transferIn:
        balance += txn.amount;
      case TransactionType.expense:
      case TransactionType.transferOut:
        balance -= txn.amount;
    }
  }
  return balance;
}

