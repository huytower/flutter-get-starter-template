import 'package:equatable/equatable.dart';

class UserLevelStatusEntity extends Equatable {
  final int level;
  final int reconciliationStreak;
  final bool hasMinBudgets;
  final bool hasPositiveCashFlow;
  final int fixedBudgetCount;
  final int completedGuidelineCount;
  final bool isVip;

  const UserLevelStatusEntity({
    required this.level,
    required this.reconciliationStreak,
    required this.hasMinBudgets,
    required this.hasPositiveCashFlow,
    required this.fixedBudgetCount,
    required this.completedGuidelineCount,
    required this.isVip,
  });

  static const int lv2RequiredStreak = 2;
  static const int lv3RequiredStreak = 4;
  static const int lv3RequiredBudgets = 3;
  static const int lv1RequiredGuidelines = 6;

  bool get canUseInvestment => level >= 2;

  bool get canUseDebtLoan => level >= 3;

  bool get canUseAiSmartEntry => level >= 3 || isVip;

  const UserLevelStatusEntity.initial()
    : level = 1,
      reconciliationStreak = 0,
      hasMinBudgets = false,
      hasPositiveCashFlow = false,
      fixedBudgetCount = 0,
      completedGuidelineCount = 0,
      isVip = false;

  @override
  List<Object?> get props => [
    level,
    reconciliationStreak,
    hasMinBudgets,
    hasPositiveCashFlow,
    fixedBudgetCount,
    completedGuidelineCount,
    isVip,
  ];
}
