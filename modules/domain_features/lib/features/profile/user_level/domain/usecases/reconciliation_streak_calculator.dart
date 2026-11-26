import '../../../../reconciliation/domain/entities/reconciliation_entity.dart';
import '../../../../reconciliation/domain/reconciliation_period_utils.dart';

/// Longest run of consecutive audit cycles that each have a reconciliation,
/// counting only reconciliations after [since] (exclusive).
///
/// An audit cycle is the 7 days ending on [auditWeekday] (1=Monday..7=Sunday,
/// matching [DateTime.weekday]), see [auditCycleOf]. A reconciliation on any
/// day of the cycle counts: reconciling early is allowed, and the next one
/// only opens once the cycle is over. A cycle with no reconciliation breaks
/// the run.
///
/// The streak is the *longest ever achieved* since [since], not a "current"
/// streak that can regress — once reached, the level it unlocks stays
/// unlocked even if the user later misses a cycle.
int longestReconciliationStreak(
  List<ReconciliationEntity> history, {
  required int auditWeekday,
  required DateTime since,
}) {
  // Several reconciliations in one cycle count once.
  final cycleEnds =
      history
          .where((r) => r.date.isAfter(since))
          .map((r) => auditCycleOf(r.date, auditWeekday).end)
          .toSet()
          .toList()
        ..sort();

  if (cycleEnds.isEmpty) return 0;

  var longest = 1;
  var current = 1;
  for (var i = 1; i < cycleEnds.length; i++) {
    // Cycle ends are UTC calendar days, so consecutive ones are exactly 7
    // days apart, across month and year boundaries alike.
    final hasConsecutive =
        cycleEnds[i].difference(cycleEnds[i - 1]).inDays == 7;
    current = hasConsecutive ? current + 1 : 1;
    if (current > longest) longest = current;
  }

  return longest;
}
