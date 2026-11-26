import 'package:injectable/injectable.dart';

import '../../../../core/domain/entities/transaction_type.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../entities/budget_limit_entity.dart';
import '../entities/budget_limit_lock_reason.dart';

/// Decides whether a budget's limit may still be edited.
///
/// The limit is locked after day 7 of the month (so budgets are set at the
/// start of a month), and once spending has been recorded against the budget
/// this month: budget spend is counted per calendar month, so an expense in
/// the budget's category this month means the cap is already in use. Deleting
/// the budget and creating it again stays allowed.
@injectable
class BudgetLimitEditPolicy {
  BudgetLimitEditPolicy(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  /// Last day of the month on which the limit may still be changed.
  static const int lastEditableDay = 7;

  /// The lock that applies today without looking at transactions, or null.
  static BudgetLimitLockReason? dayLockReason({DateTime? now}) {
    final today = now ?? DateTime.now();
    return today.day > lastEditableDay
        ? BudgetLimitLockReason.pastFirstWeek
        : null;
  }

  /// Why [budget]'s limit cannot be edited now, or null when it can.
  Future<BudgetLimitLockReason?> lockReasonFor(
    BudgetLimitEntity budget, {
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    final dayLock = dayLockReason(now: today);
    if (dayLock != null) return dayLock;

    final monthStart = DateTime(today.year, today.month, 1);
    final nextMonthStart = DateTime(today.year, today.month + 1, 1);
    final result = await _transactionRepository.getTransactionsByPeriod(
      monthStart,
      nextMonthStart,
    );
    // Without the month's transactions the rule cannot be checked; locking
    // is the safe answer for a cap the user may already be spending against.
    if (result.isError()) return BudgetLimitLockReason.hasSpending;

    final hasSpending = result.tryGetSuccess()!.any(
      (t) =>
          !t.hasDeleted &&
          t.type == TransactionType.expense &&
          t.categoryId == budget.categoryId &&
          t.date.isBefore(nextMonthStart),
    );
    return hasSpending ? BudgetLimitLockReason.hasSpending : null;
  }
}
