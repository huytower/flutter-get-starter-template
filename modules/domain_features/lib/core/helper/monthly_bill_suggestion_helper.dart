import '../../features/transaction/domain/entities/transaction_entity.dart';

const int monthlyBillDayTolerance = 3;

TransactionEntity? findMonthlyBillMatch({
  required DateTime now,
  required List<TransactionEntity> candidates,
  int dayTolerance = monthlyBillDayTolerance,
}) {
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final daysInThisMonth = DateTime(now.year, now.month + 1, 0).day;

  TransactionEntity? closest;
  int closestDiff = dayTolerance + 1;

  for (final candidate in candidates) {
    if (candidate.date.isBefore(lastMonthStart) ||
        !candidate.date.isBefore(thisMonthStart)) {
      continue;
    }
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
