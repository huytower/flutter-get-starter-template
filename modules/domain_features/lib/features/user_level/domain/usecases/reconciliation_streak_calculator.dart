import '../../../reconciliation/domain/entities/reconciliation_entity.dart';
import '../../../reconciliation/domain/reconciliation_period_utils.dart';

/// Longest run of consecutive ISO weeks that have a qualifying reconciliation
/// since [since] (exclusive), where "qualifying" means dated on [auditWeekday]
/// (1=Monday..7=Sunday, matching [DateTime.weekday]).
///
/// The streak is the *longest ever achieved* since [since], not a "current"
/// streak that can regress — once reached, the level it unlocks stays
/// unlocked even if the user later misses a week.
int longestReconciliationStreak(
  List<ReconciliationEntity> history, {
  required int auditWeekday,
  required DateTime since,
}) {
  final qualifying = history.where(
    (r) => r.date.isAfter(since) && r.date.weekday == auditWeekday,
  );

  // Dedupe multiple qualifying reconciliations in the same ISO week.
  final weeksSeen = <String, ({int yearly, int week})>{};
  for (final r in qualifying) {
    final w = isoWeekOf(r.date);
    weeksSeen['${w.yearly}-${w.week}'] = w;
  }

  final weeks = weeksSeen.values.toList()
    ..sort((a, b) {
      final byYear = a.yearly.compareTo(b.yearly);
      return byYear != 0 ? byYear : a.week.compareTo(b.week);
    });

  if (weeks.isEmpty) return 0;

  var longest = 1;
  var current = 1;
  for (var i = 1; i < weeks.length; i++) {
    final prev = weeks[i - 1];
    final w = weeks[i];
    final isConsecutive =
        (w.yearly == prev.yearly && w.week == prev.week + 1) ||
        // Year boundary: last week of prev year -> week 1 of next year.
        // prev.yearly can have 52 or 53 ISO weeks, so compare against the
        // actual last week rather than assuming 52.
        (w.yearly == prev.yearly + 1 &&
            w.week == 1 &&
            prev.week == lastIsoWeekOfYear(prev.yearly));
    current = isConsecutive ? current + 1 : 1;
    if (current > longest) longest = current;
  }

  return longest;
}
