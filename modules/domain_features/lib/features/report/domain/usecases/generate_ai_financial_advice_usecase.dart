import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/helper/ai_advice_cache_datasource.dart';
import '../../../../core/helper/ai_advice_helper.dart';
import '../../../budget_limit/domain/entities/budget_insights_entity.dart';
import '../../../budget_limit/domain/usecases/get_budget_anomalies_usecase.dart';
import '../../../budget_limit/domain/usecases/get_budget_insights_usecase.dart';
import '../../../transaction/domain/usecases/get_month_to_date_cash_flow_usecase.dart';
import '../entities/ai_advice_entity.dart';
import '../entities/financial_runway_entity.dart';
import 'get_financial_runway_usecase.dart';

/// Phase 3.8 — the one genuinely LLM-shaped Phase 3 action:
/// [GetBudgetAnomaliesUseCase]'s own doc comment flags "suggest income
/// increase strategies" as deliberately deferred, and this use case is that
/// deferred work, folded together with the spec's separate "Spending
/// Optimization" section into one combined narrative.
///
/// Deliberately reads [GetMonthToDateCashFlowUseCase] and
/// [GetBudgetAnomaliesUseCase] directly rather than only through
/// [GetBudgetInsightsUseCase] — that entity only exposes a deficit
/// amount/anomaly *count*, but the prompt needs real income/expense figures
/// even in the no-deficit case, and per-category anomaly detail to write
/// something specific.
///
/// No consent/cap gating here — the caller (`ReportController`) is
/// responsible for that, mirroring how `ParseQuickEntryUseCase.parseWithCloud`
/// also assumes gating already passed before it's invoked.
@lazySingleton
class GenerateAiFinancialAdviceUseCase {
  GenerateAiFinancialAdviceUseCase(
    this._getInsights,
    this._getAnomalies,
    this._getRunway,
    this._getCashFlow,
    this._cache,
  );

  final GetBudgetInsightsUseCase _getInsights;
  final GetBudgetAnomaliesUseCase _getAnomalies;
  final GetFinancialRunwayUseCase _getRunway;
  final GetMonthToDateCashFlowUseCase _getCashFlow;
  final AiAdviceCacheDataSource _cache;

  /// Returns null when the cloud call itself fails/returns empty — never
  /// throws, matching [CcGeminiHelper.generateText]'s own fail-silent
  /// contract. A missing/failed local data source (insights/anomalies/
  /// runway/cash flow) degrades to `null`/empty for that one input rather
  /// than blocking advice generation entirely.
  Future<AiAdviceEntity?> call() async {
    final results = await Future.wait([
      _getInsights.call(),
      _getAnomalies.call(),
      _getRunway.call(),
      _getCashFlow.call(),
    ]);

    final insights =
        (results[0] as Result<BudgetInsightsEntity, dynamic>)
            .tryGetSuccess();
    final anomalies =
        (results[1] as Result<List<BudgetAnomalyEntity>, dynamic>)
            .tryGetSuccess();
    final runway =
        (results[2] as Result<FinancialRunwayEntity, dynamic>)
            .tryGetSuccess();
    final cashFlow =
        (results[3] as Result<CashFlowEntity, dynamic>).tryGetSuccess();

    final prompt = buildAiFinancialAdvicePrompt(
      cashFlow: cashFlow,
      insights: insights,
      anomalies: anomalies ?? const [],
      runway: runway,
    );

    final raw = await CcGeminiHelper.generateText(prompt: prompt);
    if (raw == null || raw.trim().isEmpty) return null;

    final entity = AiAdviceEntity(text: raw.trim(), generatedAt: DateTime.now());
    await _cache.saveAdvice(text: entity.text, generatedAt: entity.generatedAt);
    return entity;
  }
}
