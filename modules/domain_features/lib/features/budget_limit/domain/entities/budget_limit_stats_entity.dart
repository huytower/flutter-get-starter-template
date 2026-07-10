import 'dart:ui';

import 'package:equatable/equatable.dart';

import 'budget_limit_entity.dart';

enum BudgetLimitStatus { safe, over }

/// A budget paired with its computed spending and the category's display data.
class BudgetLimitStatsEntity extends Equatable {
  final BudgetLimitEntity budget;
  final int spent;

  /// Category icon codePoint (0 = no category found, card shows fallback icon).
  final int iconCode;
  final String? iconFamily;

  /// Category colour; null falls back to the theme primary.
  final Color? color;

  const BudgetLimitStatsEntity({
    required this.budget,
    required this.spent,
    this.iconCode = 0,
    this.iconFamily,
    this.color,
  });

  /// Amount still available ("còn X"); negative when over the limit.
  int get remaining => budget.limit - spent;

  /// True only once spending exceeds the limit ("tiêu quá hạn mức");
  /// spending exactly the limit stays safe.
  bool get isOver => spent > budget.limit;

  /// Discrete state for the UI.
  BudgetLimitStatus get status =>
      isOver ? BudgetLimitStatus.over : BudgetLimitStatus.safe;

  /// Spent fraction in 0..1 for the progress bar.
  double get progress {
    if (budget.limit <= 0) return 0;
    return (spent / budget.limit).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [budget.id, spent, iconCode, iconFamily, color];
}
