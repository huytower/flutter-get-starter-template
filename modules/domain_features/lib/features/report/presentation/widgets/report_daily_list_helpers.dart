import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../transaction/domain/services/reconciled_period_lock.dart';

bool computeIsInflow(TransactionEntity transaction) {
  final type = transaction.type;
  return type == TransactionType.income ||
      type == TransactionType.investmentReturn ||
      type == TransactionType.debtBorrow ||
      type == TransactionType.debtCollect;
}

/// Whether [transaction] is closed by a reconciliation (dated at or before
/// [reconciledUntil]): the report shows an info button instead of edit/delete.
/// Transfers and deleted rows never offer actions, so they are left out.
bool hasReconciledTransaction(
  TransactionEntity transaction,
  DateTime? reconciledUntil,
) =>
    !transaction.hasDeleted &&
    !transaction.hasTransfer &&
    ReconciledPeriodLock.hasLocked(transaction, reconciledUntil);

/// Whether the report may offer edit/delete for [transaction]: the type allows
/// it, it is within the edit window, and it is not in a reconciled period
/// (dated at or before [reconciledUntil], see `ReconciledPeriodLock`).
bool hasEditableTransaction(
  TransactionEntity transaction, {
  DateTime? reconciledUntil,
}) {
  if (transaction.hasDeleted) return false;
  if (transaction.hasTransfer) return false;
  if (ReconciledPeriodLock.hasLocked(transaction, reconciledUntil)) {
    return false;
  }
  return DateTime.now().difference(transaction.date).inDays <=
      transactionEditWindowDays;
}

Color computeAmountColor(BuildContext context, TransactionEntity transaction) {
  switch (transaction.type) {
    case TransactionType.income:
      return context.incomeAccent;
    case TransactionType.investmentOut:
      return context.investmentAccent;
    case TransactionType.investmentReturn:
      return context.investmentAccent.secondaryShade;
    case TransactionType.debtBorrow:
      return context.borrowAccent;
    case TransactionType.debtRepay:
      return context.borrowAccent.secondaryShade;
    case TransactionType.debtLend:
      return context.lendAccent;
    case TransactionType.debtCollect:
      return context.lendAccent.secondaryShade;
    case TransactionType.expense:
    default:
      return context.expenseAccent;
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
