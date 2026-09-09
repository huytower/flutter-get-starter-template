import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';

bool computeIsInflow(TransactionEntity transaction) {
  final type = transaction.type;
  return type == TransactionType.income ||
      type == TransactionType.investmentReturn ||
      type == TransactionType.debtBorrow ||
      type == TransactionType.debtCollect;
}

bool isEditableTransaction(TransactionEntity transaction) {
  if (transaction.isDeleted) return false;
  if (transaction.isTransfer) return false;
  return DateTime.now().difference(transaction.date).inDays <=
      transactionEditWindowDays;
}

Color computeAmountColor(BuildContext context, TransactionEntity transaction) {
  final scheme = context.ccColorScheme;
  switch (transaction.type) {
    case TransactionType.income:
      return PrjColors.success;
    case TransactionType.investmentOut:
      return scheme.investment;
    case TransactionType.investmentReturn:
      return scheme.investmentSecondary;
    case TransactionType.debtLend:
    case TransactionType.debtRepay:
      return scheme.liabilitySecondary;
    case TransactionType.debtBorrow:
    case TransactionType.debtCollect:
      return scheme.liability;
    case TransactionType.expense:
    default:
      return PrjColors.error;
  }
}

double computeDailyTotal(
  List<TransactionEntity> transactions, {
  required bool includeInvestmentAndLiability,
}) {
  return transactions.fold<double>(0, (sum, tx) {
    if (tx.type == TransactionType.income) return sum + tx.amount;
    if (tx.type == TransactionType.expense) return sum - tx.amount;
    if (includeInvestmentAndLiability) {
      if (tx.type == TransactionType.investmentReturn) return sum + tx.amount;
      if (tx.type == TransactionType.investmentOut) return sum - tx.amount;
      if (tx.type == TransactionType.debtBorrow) return sum + tx.amount;
      if (tx.type == TransactionType.debtLend) return sum - tx.amount;
      if (tx.type == TransactionType.debtRepay) return sum - tx.amount;
      if (tx.type == TransactionType.debtCollect) return sum + tx.amount;
    }
    return sum;
  });
}
