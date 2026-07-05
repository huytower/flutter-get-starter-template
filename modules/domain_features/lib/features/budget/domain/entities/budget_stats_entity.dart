import 'package:equatable/equatable.dart';

import 'budget_entity.dart';

/// Spending state of a budget, driving the card's colour and warning.
enum BudgetStatus {
  /// Comfortably within the limit.
  safe,

  /// Approaching the limit ("sắp chạm mức trần") — amber warning.
  nearLimit,

  /// Reached or exceeded the limit ("tiêu quá hạn mức") — red warning.
  over,
}

/// A budget paired with its computed spending ("Cảnh báo vượt rào").
///
/// Replaces the web `sum_thong_ke_ngan_sach` view — `spent` is aggregated in
/// Dart from the transactions linked to the budget within its period.
class BudgetStatsEntity extends Equatable {
  final BudgetEntity budget;
  final int spent;

  const BudgetStatsEntity({required this.budget, required this.spent});

  /// Fraction of the limit at which the "sắp chạm hạn mức" warning begins.
  static const double warnThreshold = 0.8;

  /// Amount still available ("còn X"); negative when over the limit.
  int get remaining => budget.limit - spent;

  /// True once spending reaches or exceeds the limit ("tiêu quá hạn mức").
  bool get isOver => spent >= budget.limit;

  /// True while spending is in [warnThreshold]..limit (approaching the cap).
  bool get isNearLimit =>
      !isOver && budget.limit > 0 && spent >= budget.limit * warnThreshold;

  /// Discrete state for the UI.
  BudgetStatus get status {
    if (isOver) return BudgetStatus.over;
    if (isNearLimit) return BudgetStatus.nearLimit;
    return BudgetStatus.safe;
  }

  /// Spent fraction in 0..1 for the progress bar.
  double get progress {
    if (budget.limit <= 0) return 0;
    return (spent / budget.limit).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [budget.id, spent];
}
