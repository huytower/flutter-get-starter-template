import 'package:equatable/equatable.dart';

/// Computed unlock state for the LV1/LV2/LV3 progression.
///
/// LV1 (default): Investment and Debt/Loan are hidden everywhere, to build
/// the habit of disciplined weekly reconciliation first.
/// LV2: unlocks Investment once [reconciliationStreak] reaches 2.
/// LV3: unlocks Debt/Loan once [reconciliationStreak] reaches 4 AND
/// [hasMinBudgets] AND [hasPositiveCashFlow] all hold.
class UserLevelStatusEntity extends Equatable {
  /// 1, 2, or 3. Monotonic — never decreases once reached.
  final int level;

  /// Longest run of consecutive ISO weeks with a qualifying reconciliation
  /// (on the user's configured audit weekday) since the anchor date.
  final int reconciliationStreak;

  /// True when at least 3 active fixed-price ("mức sống tối thiểu") budgets
  /// are set.
  final bool hasMinBudgets;

  /// True when this month's income minus expense (month-to-date) is > 0.
  final bool hasPositiveCashFlow;

  /// Number of active fixed-price budgets (for progress display).
  final int fixedBudgetCount;

  const UserLevelStatusEntity({
    required this.level,
    required this.reconciliationStreak,
    required this.hasMinBudgets,
    required this.hasPositiveCashFlow,
    required this.fixedBudgetCount,
  });

  static const int lv2RequiredStreak = 2;
  static const int lv3RequiredStreak = 4;
  static const int lv3RequiredBudgets = 3;

  bool get canUseInvestment => level >= 2;

  bool get canUseDebtLoan => level >= 3;

  const UserLevelStatusEntity.initial()
    : level = 1,
      reconciliationStreak = 0,
      hasMinBudgets = false,
      hasPositiveCashFlow = false,
      fixedBudgetCount = 0;

  @override
  List<Object?> get props => [
    level,
    reconciliationStreak,
    hasMinBudgets,
    hasPositiveCashFlow,
    fixedBudgetCount,
  ];
}
