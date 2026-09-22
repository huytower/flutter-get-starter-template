import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../budget_limit/domain/repositories/budget_limit_repository.dart';
import '../../../../reconciliation/domain/usecases/get_reconciliation_history_usecase.dart';
import '../../../../transaction/domain/entities/transaction_entity.dart';
import '../../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../entities/user_level_status_entity.dart';
import 'reconciliation_streak_calculator.dart';

@lazySingleton
class GetUserLevelStatusUseCase {
  GetUserLevelStatusUseCase(
    this._getReconciliationHistory,
    this._budgetLimitRepository,
    this._transactionRepository,
    this._profileRepository,
  );

  final GetReconciliationHistoryUseCase _getReconciliationHistory;
  final BudgetLimitRepository _budgetLimitRepository;
  final TransactionRepository _transactionRepository;
  final ProfileRepository _profileRepository;

  Future<Result<UserLevelStatusEntity, CcFailure>> call() async {
    final settings = await _profileRepository.getSettings();

    final since =
        settings.weeklyAuditDayChangedAt ??
        settings.levelFeatureAnchorAt ??
        DateTime.now();
    final auditWeekday = settings.weeklyAuditDayIndex + 1;

    final historyResult = await _getReconciliationHistory.call();
    if (historyResult.isError()) {
      return Error(historyResult.tryGetError()!);
    }
    final streak = longestReconciliationStreak(
      historyResult.tryGetSuccess()!,
      auditWeekday: auditWeekday,
      since: since,
    );

    final budgetsResult = await _budgetLimitRepository.getBudgets(
      activeOnly: true,
    );
    if (budgetsResult.isError()) {
      return Error(budgetsResult.tryGetError()!);
    }
    final fixedBudgetCount = budgetsResult
        .tryGetSuccess()!
        .where((b) => b.isFixedPrice)
        .length;
    final hasMinBudgets =
        fixedBudgetCount >= UserLevelStatusEntity.lv3RequiredBudgets;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final txnResult = await _transactionRepository.getTransactionsByPeriod(
      startOfMonth,
      now,
    );
    if (txnResult.isError()) {
      return Error(txnResult.tryGetError()!);
    }
    var income = 0;
    var expense = 0;
    for (final t in txnResult.tryGetSuccess()!) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else if (t.type == TransactionType.expense) {
        expense += t.amount;
      }
    }
    final hasPositiveCashFlow = (income - expense) > 0;

    // Level 2 logic: all guideline tasks completed AND reconciliation streak >= 2.
    final completedGuidelineCount = settings.completedGuidelineTaskIds.length;
    final guidelineCompleted =
        completedGuidelineCount >= UserLevelStatusEntity.lv1RequiredGuidelines;

    // 1. Calculate organic level based on milestones
    int organicLevel = 1;
    if (streak >= UserLevelStatusEntity.lv3RequiredStreak &&
        hasMinBudgets &&
        hasPositiveCashFlow) {
      organicLevel = 3;
    } else if (streak >= UserLevelStatusEntity.lv2RequiredStreak &&
        guidelineCompleted) {
      organicLevel = 2;
    }

    // 2. Persist highest organic level reached
    if (organicLevel > settings.highestUserLevelReached) {
      await _profileRepository.saveSettings(
        settings.copyWith(highestUserLevelReached: organicLevel),
      );
    } else if (organicLevel < settings.highestUserLevelReached) {
      organicLevel = settings.highestUserLevelReached;
    }

    // 3. Final display level: Milestones OR VIP override
    int level = organicLevel;
    if (settings.isVip) {
      level = 3;
    }

    return Success(
      UserLevelStatusEntity(
        level: level,
        reconciliationStreak: streak,
        hasMinBudgets: hasMinBudgets,
        hasPositiveCashFlow: hasPositiveCashFlow,
        fixedBudgetCount: fixedBudgetCount,
        completedGuidelineCount: completedGuidelineCount,
        isVip: settings.isVip,
      ),
    );
  }
}
