import 'package:equatable/equatable.dart';

/// The user's earned level plus the VIP entitlement, and the feature gates
/// derived from them.
///
/// Every gate has **two independent unlock paths** (docs/BUSINESS_REQUIREMENT.md
/// §3): the earned [level] (§8) **or** [hasVip]. Neither path depends on the
/// other, so each gate is `level >= N || hasVip`:
/// - LV2 unlocks the Investment tab only; Liability / Lend stay locked.
/// - LV3 unlocks Liability / Lend and AI Smart Entry.
/// - VIP unlocks all of them at any level, without changing [level].
///
/// VIP is a free Profile switch today; it will be hidden and sold as paid VIP
/// later. That changes only where [hasVip] comes from, not these gates.
class UserLevelStatusEntity extends Equatable {
  final int level;
  final int reconciliationStreak;
  final bool hasMinBudgets;
  final bool hasPositiveCashFlow;
  final int fixedBudgetCount;
  final int completedGuidelineCount;
  final bool hasVip;

  const UserLevelStatusEntity({
    required this.level,
    required this.reconciliationStreak,
    required this.hasMinBudgets,
    required this.hasPositiveCashFlow,
    required this.fixedBudgetCount,
    required this.completedGuidelineCount,
    required this.hasVip,
  });

  static const int lv2RequiredStreak = 2;
  static const int lv3RequiredStreak = 4;
  static const int lv3RequiredBudgets = 3;

  /// The six LV1 guideline tasks (§4.A) that LV2 requires. The later
  /// `investment` / `liability` tasks do not count toward it.
  static const List<String> lv1GuidelineTaskIds = [
    'birth_year',
    'categories',
    'wallet_balance',
    'budget_limit',
    'min_living',
    'first_transaction',
  ];
  static const int lv1RequiredGuidelines = 6;

  /// How many of the [lv1GuidelineTaskIds] are among [completedTaskIds].
  static int countLv1GuidelineTasks(Iterable<String> completedTaskIds) =>
      lv1GuidelineTaskIds.where(completedTaskIds.contains).length;

  /// Level that unlocks the Investment tab on the level path.
  static const int investmentUnlockLevel = 2;

  /// Level that unlocks the Liability and Lend tabs and AI Smart Entry.
  static const int advancedUnlockLevel = 3;

  /// Investment tab: reached LV2, or VIP.
  bool get canUseInvestment => level >= investmentUnlockLevel || hasVip;

  /// Liability and Lend tabs: reached LV3, or VIP. Still locked at LV2.
  bool get canUseLiability => level >= advancedUnlockLevel || hasVip;

  /// AI Smart Entry: reached LV3, or VIP.
  bool get canUseAiSmartEntry => level >= advancedUnlockLevel || hasVip;

  const UserLevelStatusEntity.initial()
    : level = 1,
      reconciliationStreak = 0,
      hasMinBudgets = false,
      hasPositiveCashFlow = false,
      fixedBudgetCount = 0,
      completedGuidelineCount = 0,
      hasVip = false;

  @override
  List<Object?> get props => [
    level,
    reconciliationStreak,
    hasMinBudgets,
    hasPositiveCashFlow,
    fixedBudgetCount,
    completedGuidelineCount,
    hasVip,
  ];
}
