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

