import 'package:domain_features/core/domain/entities/transaction_entity.dart';

enum ReportFilterType {
  all,
  expense,
  income,
  investment,
  liability,
  lend;

  /// Whether [transaction] belongs in the daily list under this filter.
  bool matches(TransactionEntity transaction) => switch (this) {
    all => true,
    expense => transaction.type == TransactionType.expense,
    income => transaction.type == TransactionType.income,
    investment => transaction.hasInvestmentActivity,
    liability =>
      transaction.type == TransactionType.debtBorrow ||
          transaction.type == TransactionType.debtRepay,
    lend =>
      transaction.type == TransactionType.debtLend ||
          transaction.type == TransactionType.debtCollect,
  };
}
