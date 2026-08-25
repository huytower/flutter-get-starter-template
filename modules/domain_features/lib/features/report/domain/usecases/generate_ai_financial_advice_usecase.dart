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

/// Generates the AI financial-advice narrative for the Report page.
///
/// Reads [GetMonthToDateCashFlowUseCase] and [GetBudgetAnomaliesUseCase]
/// directly rather than only through [GetBudgetInsightsUseCase] — that
/// entity only exposes a deficit amount/anomaly count, but the prompt needs
/// real income/expense figures and per-category anomaly detail.
///
/// No consent/cap gating here — the caller (`ReportController`) already
/// did that, same assumption `ParseQuickEntryUseCase.parseWithCloud` makes.
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

  /// Never throws; returns null on a failed/empty cloud call. A failed
  /// local data source degrades to null/empty for that one input rather
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
