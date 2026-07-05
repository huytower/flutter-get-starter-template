import 'package:equatable/equatable.dart';

/// Income vs expense totals for a single calendar month — one pair of bars in
/// the trend chart ("So sánh thu nhập và chi tiêu theo từng tháng").
class MonthlySummaryEntity extends Equatable {
  final int year;

  /// 1..12.
  final int month;

  final int income;
  final int expense;

  const MonthlySummaryEntity({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });

  /// Net savings for the month (positive = surplus).
  int get net => income - expense;

  /// Short `MM/yy` axis label (e.g. `07/26`).
  String get shortLabel {
    final mm = month.toString().padLeft(2, '0');
    final yy = (year % 100).toString().padLeft(2, '0');
    return '$mm/$yy';
  }

  @override
  List<Object?> get props => [year, month, income, expense];
}
