/// The date a new entry is recorded with.
///
/// A form shows a day, not a time; the time it carries comes from when it was
/// opened or last reset. An entry for today is stamped with the moment it is
/// saved, so one made after a reconciliation is never dated before it (which
/// would close it to edits at once). An earlier day is kept as chosen.
///
/// ```dart
/// date: EntryDate.recordedAt(params.date),
/// ```
abstract final class EntryDate {
  static DateTime recordedAt(DateTime chosen, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final hasToday =
        chosen.year == current.year &&
        chosen.month == current.month &&
        chosen.day == current.day;
    return hasToday ? current : chosen;
  }
}
