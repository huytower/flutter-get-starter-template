import '../report_range.dart';

/// The date window a [ReportRange]/offset resolves to, shared by every
/// report trend use case so the weekly/monthly/yearly windowing math
/// ([GetTrendDataUseCase]'s original logic) lives in one place.
class TrendWindow {
  final DateTime start;
  final DateTime end;
  final int pointsCount;

  const TrendWindow({
    required this.start,
    required this.end,
    required this.pointsCount,
  });
}

TrendWindow trendWindowFor(ReportRange range, int offset) {
  final now = DateTime.now();
  switch (range) {
    case ReportRange.weekly:
      // Always the last 4 weeks, no navigation.
      return TrendWindow(
        start: DateTime(now.year, now.month, now.day - 27),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
        pointsCount: 4,
      );
    case ReportRange.monthly:
      final refMonth = now.month - (offset * 3);
      return TrendWindow(
        start: DateTime(now.year, refMonth - 2, 1),
        end: DateTime(now.year, refMonth + 1, 0, 23, 59, 59, 999),
        pointsCount: 3,
      );
    case ReportRange.yearly:
      final refMonth = now.month - (offset * 12);
      return TrendWindow(
        start: DateTime(now.year, refMonth - 11, 1),
        end: DateTime(now.year, refMonth + 1, 0, 23, 59, 59, 999),
        pointsCount: 12,
      );
  }
}
