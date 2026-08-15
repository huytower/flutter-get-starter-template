import 'package:equatable/equatable.dart';

import 'budget_limit_stats_entity.dart';

/// A near-limit/over budget with its Phase 3.4 pacing suggestion (80%:
/// remaining days + suggested daily spend from the remaining 20%; 100%:
/// remaining days, daily spend already at 0).
class BudgetPacingWarning extends Equatable {
  final String budgetName;
  final BudgetLimitStatus status;
  final int daysRemaining;
  final int suggestedDailySpend;

  const BudgetPacingWarning({
    required this.budgetName,
    required this.status,
    required this.daysRemaining,
    required this.suggestedDailySpend,
  });

  @override
  List<Object?> get props => [
    budgetName,
    status,
    daysRemaining,
    suggestedDailySpend,
  ];
}

/// A budget that has crossed one of the 120/150/200% penalty tiers.
class BudgetPenaltyWarning extends Equatable {
  final String budgetName;
  final int percentUsed;
  final BudgetPenaltyTier tier;

  const BudgetPenaltyWarning({
    required this.budgetName,
    required this.percentUsed,
    required this.tier,
  });

  @override
  List<Object?> get props => [budgetName, percentUsed, tier];
}

/// Aggregated Phase 3.4 "AI Actions" for the Budget Allocation page — empty
/// (see [hasAnything]) when nothing needs the user's attention, matching the
/// spec's "praise smart spending, don't nag" Smart Budgeting philosophy.
class BudgetInsightsEntity extends Equatable {
  final List<BudgetPacingWarning> pacingWarnings;
  final List<BudgetPenaltyWarning> penaltyWarnings;
  final bool isDeficit;
  final int deficitAmount;
  final int anomalyCount;

  const BudgetInsightsEntity({
    required this.pacingWarnings,
    required this.penaltyWarnings,
    required this.isDeficit,
    required this.deficitAmount,
    required this.anomalyCount,
  });

  bool get hasAnything =>
      pacingWarnings.isNotEmpty ||
      penaltyWarnings.isNotEmpty ||
      isDeficit ||
      anomalyCount > 0;

  @override
  List<Object?> get props => [
    pacingWarnings,
    penaltyWarnings,
    isDeficit,
    deficitAmount,
    anomalyCount,
  ];
}
