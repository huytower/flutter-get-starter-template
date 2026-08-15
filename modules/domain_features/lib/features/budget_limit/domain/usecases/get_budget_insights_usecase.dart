import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/helper/budget_pacing_helper.dart';
import '../../../transaction/domain/usecases/get_month_to_date_cash_flow_usecase.dart';
import '../entities/budget_insights_entity.dart';
import '../entities/budget_limit_stats_entity.dart';
import 'get_budget_anomalies_usecase.dart';
import 'get_budget_limit_stats_usecase.dart';

/// Composes Phase 3.4's pacing warnings, penalty tiers, deficit detection,
/// and anomaly count into one entity for the Budget Allocation page's
/// insights panel.
@lazySingleton
class GetBudgetInsightsUseCase {
  GetBudgetInsightsUseCase(
    this._getBudgetStats,
    this._getCashFlow,
    this._getAnomalies,
  );

  final GetBudgetLimitStatsUseCase _getBudgetStats;
  final GetMonthToDateCashFlowUseCase _getCashFlow;
  final GetBudgetAnomaliesUseCase _getAnomalies;

  Future<Result<BudgetInsightsEntity, CcFailure>> call() async {
    final statsResult = await _getBudgetStats.call();
    if (statsResult.isError()) return Error(statsResult.tryGetError()!);
    final stats = statsResult.tryGetSuccess()!;

    final daysRemaining = daysRemainingInMonth();
    final pacingWarnings = <BudgetPacingWarning>[
      for (final stat in stats)
        if (stat.status != BudgetLimitStatus.safe)
          BudgetPacingWarning(
            budgetName: stat.budget.name,
            status: stat.status,
            daysRemaining: daysRemaining,
            suggestedDailySpend: suggestedDailySpend(
              stat.remaining,
              daysRemaining,
            ),
          ),
    ];

    final penaltyWarnings = <BudgetPenaltyWarning>[
      for (final stat in stats)
        if (stat.penaltyTier != BudgetPenaltyTier.none)
          BudgetPenaltyWarning(
            budgetName: stat.budget.name,
            percentUsed: (stat.percentUsed * 100).round(),
            tier: stat.penaltyTier,
          ),
    ];

    final cashFlowResult = await _getCashFlow.call();
    final cashFlow = cashFlowResult.tryGetSuccess();

    final anomaliesResult = await _getAnomalies.call();
    final anomalyCount = anomaliesResult.tryGetSuccess()?.length ?? 0;

    return Success(
      BudgetInsightsEntity(
        pacingWarnings: pacingWarnings,
        penaltyWarnings: penaltyWarnings,
        isDeficit: cashFlow?.isDeficit ?? false,
        deficitAmount: cashFlow != null ? -cashFlow.net : 0,
        anomalyCount: anomalyCount,
      ),
    );
  }
}
