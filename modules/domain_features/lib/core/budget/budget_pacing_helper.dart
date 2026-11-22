/// Phase 3.4 "Budget Warning Thresholds" (80%: calculate remaining days,
/// suggest daily spending limit from the remaining 20%; 100%: suggest
/// remaining days, recommend limiting daily spending).

/// Days left in [now]'s calendar month, inclusive of today.
int daysRemainingInMonth([DateTime? now]) {
  final n = now ?? DateTime.now();
  final lastDayOfMonth = DateTime(n.year, n.month + 1, 0).day;
  return lastDayOfMonth - n.day + 1;
}

/// Suggested daily spend for the rest of the month from [remaining] budget
/// over [daysRemaining] days. Clamped to 0 when the budget is already
/// exhausted (negative remaining) — there's no positive daily allowance left
/// to suggest.
int suggestedDailySpend(int remaining, int daysRemaining) {
  if (remaining <= 0 || daysRemaining <= 0) return 0;
  return (remaining / daysRemaining).floor();
}
