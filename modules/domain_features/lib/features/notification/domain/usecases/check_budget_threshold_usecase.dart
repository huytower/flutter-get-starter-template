import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../budget_limit/domain/entities/budget_limit_stats_entity.dart';
import '../../../budget_limit/domain/usecases/get_budget_limit_stats_usecase.dart';
import '../../notification_service.dart';
import '../../reminder_ids.dart';

/// Phase 3.4 budget-threshold notifications. Called right after a successful
/// expense save with the just-recorded amount — compares spend before vs
/// after *this* transaction against the 80%/100% thresholds and fires a
/// local notification only on the exact transaction that crosses one. This
/// mirrors `GetBudgetOverLimitCountUseCase`'s crossing-detection trick, so no
/// "already notified this month" state needs to be persisted anywhere: the
/// event itself (a fresh crossing) is the only trigger.
@lazySingleton
class CheckBudgetThresholdUseCase {
  CheckBudgetThresholdUseCase(this._getBudgetStats, this._notificationService);

  final GetBudgetLimitStatsUseCase _getBudgetStats;
  final NotificationService _notificationService;

  Future<void> call({
    required String categoryId,
    required int transactionAmount,
  }) async {
    if (categoryId.isEmpty || transactionAmount <= 0) return;

    final result = await _getBudgetStats.call();
    final stats = result.tryGetSuccess();
    if (stats == null) return;

    for (final stat in stats) {
      if (stat.budget.categoryId != categoryId) continue;
      final limit = stat.budget.limit;
      if (limit <= 0) continue;

      final after = stat.spent;
      final before = after - transactionAmount;

      if (before <= limit && after > limit) {
        await _notify(stat, 'over');
      } else if (before < limit * BudgetLimitStatsEntity.nearLimitThreshold &&
          after >= limit * BudgetLimitStatsEntity.nearLimitThreshold) {
        await _notify(stat, 'near');
      }
    }
  }

  Future<void> _notify(BudgetLimitStatsEntity stat, String tier) async {
    final isOver = tier == 'over';
    await _notificationService.showNow(
      id: ReminderIds.budgetThreshold(stat.budget.id, tier),
      title: el.tr(
        isOver ? CcLocaleKeys.budget_over_limit : CcLocaleKeys.budget_near_limit,
      ),
      body: el.tr(
        isOver
            ? CcLocaleKeys.notification_budget_over_body
            : CcLocaleKeys.notification_budget_near_limit_body,
        namedArgs: {'name': stat.budget.name},
      ),
    );
  }
}
