import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:intl/intl.dart';
import 'package:message/prj_locale_keys.dart';

import '../entities/trend_data_entity.dart';
import '../report_range.dart';
import 'trend_window.dart';

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
            PrjLocaleKeys.report_trend_week_label,
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
