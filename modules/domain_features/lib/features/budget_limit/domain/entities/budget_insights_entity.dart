import 'package:equatable/equatable.dart';

import 'budget_pacing_warning.dart';
import 'budget_penalty_warning.dart';

export 'budget_pacing_warning.dart';
export 'budget_penalty_warning.dart';

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
