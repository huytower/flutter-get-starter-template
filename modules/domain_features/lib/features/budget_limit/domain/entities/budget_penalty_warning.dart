import 'package:equatable/equatable.dart';

import 'budget_limit_stats_entity.dart';

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

