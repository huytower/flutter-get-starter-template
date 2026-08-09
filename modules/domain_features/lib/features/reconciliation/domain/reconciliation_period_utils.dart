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

/// Number of ISO-8601 weeks in [year] — 52 for most years, 53 for "leap
/// weeks" years. December 28 always falls in the last ISO week of its
/// calendar year, so its week number is the answer.
int lastIsoWeekOfYear(int year) => isoWeekOf(DateTime.utc(year, 12, 28)).week;
