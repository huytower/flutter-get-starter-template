/// The time window a spending report is aggregated over.
enum ReportRange {
  /// Tab "Tháng" - Show last 4 weeks (28 days).
  weekly,

  /// Tab "3 Tháng" - Show 3 months leading up to today.
  monthly,

  /// Tab "Năm" - Show 12 months leading up to today.
  yearly,
}

extension ReportRangeX on ReportRange {
  /// Inclusive start..end bounds for [reference] (defaults to now).
  ({DateTime start, DateTime end}) bounds([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    switch (this) {
      case ReportRange.weekly:
        // Show last 4 weeks (28 days)
        final end = _endOfDay(now);
        final start = DateTime(now.year, now.month, now.day - 27, 0, 0, 0, 0);
        return (start: start, end: end);
      case ReportRange.monthly:
        // Show 3 months leading up to today
        final start = DateTime(now.year, now.month - 2, 1);
        final end = _endOfDay(now);
        return (start: start, end: end);
      case ReportRange.yearly:
        // Show 12 months leading up to today
        final start = DateTime(now.year - 1, now.month + 1, 1);
        final end = _endOfDay(now);
        return (start: start, end: end);
    }
  }

  static DateTime _endOfDay(DateTime day) =>
      DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
}
