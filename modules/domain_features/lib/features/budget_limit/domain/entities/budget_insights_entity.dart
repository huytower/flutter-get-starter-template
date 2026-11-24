import 'package:equatable/equatable.dart';

import 'budget_limit_stats_entity.dart';

/// A near-limit/over budget with its Phase 3.4 pacing suggestion (80%:
/// remaining days + suggested daily spend from the remaining 20%; 100%:
/// remaining days, daily spend already at 0).
class BudgetPacingWarning extends Equatable {
  final String budgetName;
  final String? categoryNameKey;
  final BudgetLimitStatus status;
  final int daysRemaining;
  final int suggestedDailySpend;

  const BudgetPacingWarning({
    required this.budgetName,
    this.categoryNameKey,
    required this.status,
    required this.daysRemaining,
    required this.suggestedDailySpend,
  });

  @override
  List<Object?> get props => [
    budgetName,
    categoryNameKey,
    status,
    daysRemaining,
    suggestedDailySpend,
  ];
}

/// A budget that has crossed one of the 120/150/200% penalty tiers.
class BudgetPenaltyWarning extends Equatable {
  final String budgetName;
  final String? categoryNameKey;
  final int percentUsed;
  final BudgetPenaltyTier tier;

  const BudgetPenaltyWarning({
    required this.budgetName,
    this.categoryNameKey,
    required this.percentUsed,
    required this.tier,
  });

  @override
  List<Object?> get props => [budgetName, categoryNameKey, percentUsed, tier];
}

/// Aggregated Phase 3.4 "AI Actions" for the Budget Allocation page — empty
/// (see [hasAnything]) when nothing needs the user's attention, matching the
/// spec's "praise smart spending, don't nag" Smart Budgeting philosophy.
class BudgetInsightsEntity extends Equatable {
  final List<BudgetPacingWarning> pacingWarnings;
  final List<BudgetPenaltyWarning> penaltyWarnings;
  final bool hasDeficit;
  final int deficitAmount;
  final int anomalyCount;
  final bool hasInflowDebtDriven;
  final int debtInflowAmount;
  final int debtInflowPercent;
  final bool hasOutflowDebtDriven;
  final int debtOutflowAmount;
  final int debtOutflowPercent;

  const BudgetInsightsEntity({
    required this.pacingWarnings,
    required this.penaltyWarnings,
    required this.hasDeficit,
    required this.deficitAmount,
    required this.anomalyCount,
    this.hasInflowDebtDriven = false,
    this.debtInflowAmount = 0,
    this.debtInflowPercent = 0,
    this.hasOutflowDebtDriven = false,
    this.debtOutflowAmount = 0,
    this.debtOutflowPercent = 0,
  });

  bool get hasAnything =>
      pacingWarnings.isNotEmpty ||
      penaltyWarnings.isNotEmpty ||
      hasDeficit ||
      hasInflowDebtDriven ||
      hasOutflowDebtDriven ||
      anomalyCount > 0;

  @override
  List<Object?> get props => [
    pacingWarnings,
    penaltyWarnings,
    hasDeficit,
    deficitAmount,
    anomalyCount,
    hasInflowDebtDriven,
    debtInflowAmount,
    debtInflowPercent,
    hasOutflowDebtDriven,
    debtOutflowAmount,
    debtOutflowPercent,
  ];
}
