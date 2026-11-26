/// ISO-8601 week number + year for [date] (mirrors the web `getWeekNumber`).
///
/// The ISO year can differ from the calendar year near year boundaries, so both
/// are returned together.
({int yearly, int week}) isoWeekOf(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final dayNum = d.weekday; // Mon = 1 .. Sun = 7
  final thursday = d.add(Duration(days: 4 - dayNum));
  final yearStart = DateTime.utc(thursday.year, 1, 1);
  final week = ((thursday.difference(yearStart).inDays) / 7).floor() + 1;
  return (yearly: thursday.year, week: week);
}

/// The audit cycle that contains [date]: the 7 calendar days that end on the
/// audit day, that day included. [auditWeekday] uses [DateTime.weekday]
/// (1 = Monday .. 7 = Sunday).
///
/// Audit day Sunday gives Monday–Sunday; audit day Wednesday gives
/// Thursday–Wednesday. Both bounds are UTC midnights of calendar days, so a
/// daylight-saving change never moves a boundary and two cycles compare equal
/// with `==`.
({DateTime start, DateTime end}) auditCycleOf(DateTime date, int auditWeekday) {
  final day = DateTime.utc(date.year, date.month, date.day);
  final end = day.add(Duration(days: (auditWeekday - day.weekday) % 7));
  return (start: end.subtract(const Duration(days: 6)), end: end);
}
