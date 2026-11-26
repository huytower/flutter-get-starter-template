/// Why a budget's limit (the amount set) cannot be edited right now.
enum BudgetLimitLockReason {
  /// It is past day 7 of the month: limits are set at the start of a month.
  pastFirstWeek,

  /// Spending was already recorded against the budget this month.
  hasSpending,
}
