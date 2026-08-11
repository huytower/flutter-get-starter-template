import 'package:easy_localization/easy_localization.dart' as el;
import 'package:intl/intl.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../entities/trend_data_entity.dart';
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

/// Groups [transactions] (already filtered to the relevant domain) into
/// [TrendPoint]s over [range]'s [window], summing [inflowAmount]/
/// [outflowAmount] per bucket. Mirrors [GetTrendDataUseCase]'s original
/// per-range grouping (7-day buckets for weekly, calendar months otherwise).
List<TrendPoint> bucketTrendPoints({
  required List<TransactionEntity> transactions,
  required ReportRange range,
  required TrendWindow window,
  required double Function(TransactionEntity) inflowAmount,
  required double Function(TransactionEntity) outflowAmount,
}) {
  final points = <TrendPoint>[];

  if (range == ReportRange.weekly) {
    for (int i = 0; i < window.pointsCount; i++) {
      final pStart = window.start.add(Duration(days: i * 7));
      final pEnd = pStart.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
      final periodTxns = transactions
          .where((t) => !t.date.isBefore(pStart) && !t.date.isAfter(pEnd))
          .toList();

      points.add(
        TrendPoint(
          label: el.tr(
            CcLocaleKeys.report_trend_week_label,
            namedArgs: {'number': '${i + 1}'},
          ),
          income: periodTxns.fold<double>(0, (s, t) => s + inflowAmount(t)),
          expense: periodTxns.fold<double>(0, (s, t) => s + outflowAmount(t)),
          date: pStart,
        ),
      );
    }
  } else {
    for (int i = 0; i < window.pointsCount; i++) {
      final mDate = DateTime(window.start.year, window.start.month + i, 1);
      final mEnd = DateTime(
        window.start.year,
        window.start.month + i + 1,
        0,
        23,
        59,
        59,
        999,
      );
      final periodTxns = transactions
          .where((t) => !t.date.isBefore(mDate) && !t.date.isAfter(mEnd))
          .toList();

      points.add(
        TrendPoint(
          label: DateFormat('M/yy').format(mDate),
          income: periodTxns.fold<double>(0, (s, t) => s + inflowAmount(t)),
          expense: periodTxns.fold<double>(0, (s, t) => s + outflowAmount(t)),
          date: mDate,
        ),
      );
    }
  }

  return points;
}
