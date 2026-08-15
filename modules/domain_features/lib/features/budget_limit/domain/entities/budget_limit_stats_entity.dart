import 'dart:ui';

import 'package:equatable/equatable.dart';

import 'budget_limit_entity.dart';

enum BudgetLimitStatus { safe, nearLimit, over }

/// Phase 3.4 "Over-budget Penalties" (see `docs/BUSINESS_REQUIREMENT.md`'s
/// Smart Budgeting section): level point deductions at 3 escalating
/// over-limit thresholds, shown on the budget chart. Deliberately kept
/// separate from [BudgetLimitStatus] (which only drives the card's
/// safe/warning/over color) so the gamification tiers can change later
/// without touching the core warning logic.
enum BudgetPenaltyTier { none, tier120, tier150, tier200 }

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

  /// Spent as a fraction of the limit, uncapped (can exceed 1.0) — the raw
  /// input for [status]/[penaltyTier], unlike [progress] which is clamped
  /// for the progress bar.
  double get percentUsed {
    if (budget.limit <= 0) return 0;
    return spent / budget.limit;
  }

  /// True from 80% up to (not including) the limit — "sắp chạm hạn mức".
  bool get isNearLimit => !isOver && percentUsed >= nearLimitThreshold;

  /// Discrete state for the UI (card color/warning row).
  BudgetLimitStatus get status {
    if (isOver) return BudgetLimitStatus.over;
    if (isNearLimit) return BudgetLimitStatus.nearLimit;
    return BudgetLimitStatus.safe;
  }

  /// Escalating over-limit penalty tier (120/150/200%), independent of
  /// [status] — see [BudgetPenaltyTier].
  BudgetPenaltyTier get penaltyTier {
    if (percentUsed >= 2.0) return BudgetPenaltyTier.tier200;
    if (percentUsed >= 1.5) return BudgetPenaltyTier.tier150;
    if (percentUsed >= 1.2) return BudgetPenaltyTier.tier120;
    return BudgetPenaltyTier.none;
  }

  static const double nearLimitThreshold = 0.8;

  /// Spent fraction in 0..1 for the progress bar.
  double get progress => percentUsed.clamp(0.0, 1.0);

  @override
  List<Object?> get props => [budget.id, spent, iconCode, iconFamily, color];
}
