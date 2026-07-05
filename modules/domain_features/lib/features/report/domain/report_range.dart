/// The time window a spending report is aggregated over.
///
/// The spec's reporting cycle is one week ("chu kỳ đang hiểu là 1 tuần"), but a
/// monthly view is offered too so users can see longer trends. The bar chart
/// (income vs expense) always spans several months regardless of this range.
enum ReportRange {
  thisWeek,
  thisMonth,
}

extension ReportRangeX on ReportRange {
  /// Inclusive start..end bounds for [reference] (defaults to now).
  ///
  /// `thisWeek` runs Monday 00:00 → Sunday 23:59:59 (ISO week, matching the
  /// reconciliation cycle). `thisMonth` runs the 1st → last day of the month.
  ({DateTime start, DateTime end}) bounds([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    switch (this) {
      case ReportRange.thisWeek:
        final startOfDay = DateTime(now.year, now.month, now.day);
        final monday = startOfDay.subtract(
          Duration(days: now.weekday - DateTime.monday),
        );
        final sunday = monday.add(const Duration(days: 6));
        return (start: monday, end: _endOfDay(sunday));
      case ReportRange.thisMonth:
        final first = DateTime(now.year, now.month, 1);
        final last = DateTime(now.year, now.month + 1, 0);
        return (start: first, end: _endOfDay(last));
    }
  }

  static DateTime _endOfDay(DateTime day) =>
      DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
}
