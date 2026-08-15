/// Phase 3.4 "AI Actions for Budget Issues" — compares this month's spend
/// against a category's historical average to flag a "khoản tăng đột biến"
/// (sudden spike). Pure percent-deviation check, no ML dependency.
///
/// Returns false when there's no real baseline ([avgPrevMonths] <= 0) — a
/// category spent on for the first time this month isn't "anomalous", it's
/// just new.
bool isAnomalousSpend(
  int thisMonthSpend,
  double avgPrevMonths, {
  double thresholdRatio = 1.5,
}) {
  if (avgPrevMonths <= 0) return false;
  return thisMonthSpend > avgPrevMonths * thresholdRatio;
}
