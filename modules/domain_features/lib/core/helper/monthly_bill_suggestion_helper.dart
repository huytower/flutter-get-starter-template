import '../../features/transaction/domain/entities/transaction_entity.dart';

const int monthlyBillDayTolerance = 3;

({DateTime lastMonthStart, DateTime thisMonthStart, DateTime nextMonthStart})
_monthStarts(DateTime now) => (
  lastMonthStart: DateTime(now.year, now.month - 1, 1),
  thisMonthStart: DateTime(now.year, now.month, 1),
  nextMonthStart: DateTime(now.year, now.month + 1, 1),
);

({DateTime start, DateTime end}) monthlyBillWindow(DateTime now) {
  final starts = _monthStarts(now);
  return (
    start: starts.lastMonthStart,
    end: starts.nextMonthStart.subtract(const Duration(microseconds: 1)),
  );
}

Set<String> _categoryKeys(TransactionEntity transaction) => {
  if (transaction.categoryId.isNotEmpty) transaction.categoryId,
  if (transaction.category.isNotEmpty) transaction.category,
};

TransactionEntity? findMonthlyBillMatch({
  required DateTime now,
  required List<TransactionEntity> candidates,
  int dayTolerance = monthlyBillDayTolerance,
}) {
  final starts = _monthStarts(now);
  final daysInThisMonth = DateTime(now.year, now.month + 1, 0).day;

  final recordedThisMonth = <String>{
    for (final candidate in candidates)
      if (!candidate.date.isBefore(starts.thisMonthStart) &&
          candidate.date.isBefore(starts.nextMonthStart))
        ..._categoryKeys(candidate),
  };

  TransactionEntity? closest;
  int closestDiff = dayTolerance + 1;

  for (final candidate in candidates) {
    if (candidate.date.isBefore(starts.lastMonthStart) ||
        !candidate.date.isBefore(starts.thisMonthStart)) {
      continue;
    }
    if (_categoryKeys(candidate).any(recordedThisMonth.contains)) continue;

    final projectedDay = candidate.date.day > daysInThisMonth
        ? daysInThisMonth
        : candidate.date.day;
    final diff = (projectedDay - now.day).abs();
    if (diff <= dayTolerance && diff < closestDiff) {
      closest = candidate;
      closestDiff = diff;
    }
  }

  return closest;
}
