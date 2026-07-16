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
