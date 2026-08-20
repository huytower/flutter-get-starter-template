import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../budget_limit/domain/repositories/budget_limit_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../reconciliation/domain/usecases/get_reconciliation_history_usecase.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
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

    // User-level progress only counts data from the anchor forward — either
    // the last time the audit day was changed, or (if never changed) the
    // moment this feature first initialized. Pre-existing dev/test data
    // never counts.
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

    int level = 1;
    if (streak >= UserLevelStatusEntity.lv3RequiredStreak &&
        hasMinBudgets &&
        hasPositiveCashFlow) {
      level = 3;
    } else if (streak >= UserLevelStatusEntity.lv2RequiredStreak &&
        guidelineCompleted) {
      level = 2;
    }

    // Level is monotonic — never decreases once reached (see
    // UserLevelStatusEntity.level doc). The signals above are recomputed
    // from live data every call, so a bad-cash-flow month or a dropped
    // budget must not revoke a level the user already unlocked.
    if (level > settings.highestUserLevelReached) {
      await _profileRepository.saveSettings(
        settings.copyWith(highestUserLevelReached: level),
      );
    } else if (level < settings.highestUserLevelReached) {
      level = settings.highestUserLevelReached;
    }

    return Success(
      UserLevelStatusEntity(
        level: level,
        reconciliationStreak: streak,
        hasMinBudgets: hasMinBudgets,
        hasPositiveCashFlow: hasPositiveCashFlow,
        fixedBudgetCount: fixedBudgetCount,
        completedGuidelineCount: completedGuidelineCount,
      ),
    );
  }
}
