import 'dart:convert';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/helper/ai_advice_helper.dart';
import '../../../budget_limit/domain/entities/budget_insights_entity.dart';
import '../../../budget_limit/domain/usecases/get_budget_anomalies_usecase.dart';
import '../../../budget_limit/domain/usecases/get_budget_insights_usecase.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
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
  );

  final GetBudgetInsightsUseCase _getInsights;
  final GetBudgetAnomaliesUseCase _getAnomalies;
  final GetFinancialRunwayUseCase _getRunway;
  final GetMonthToDateCashFlowUseCase _getCashFlow;

  static const int _maxHighlightsPerSection = 3;

  /// Never throws; returns null on a failed/empty cloud call. A failed
  /// local data source degrades to null/empty for that one input rather
  /// than blocking advice generation entirely.
  Future<AiAdviceEntity?> call() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    final results = await Future.wait([
      _getInsights.call(),
      _getAnomalies.call(),
      _getRunway.call(),
      _getCashFlow.call(),
    ]);

    final insights = (results[0] as Result<BudgetInsightsEntity, dynamic>)
        .tryGetSuccess();
    final anomalies = (results[1] as Result<List<BudgetAnomalyEntity>, dynamic>)
        .tryGetSuccess();
    final runway = (results[2] as Result<FinancialRunwayEntity, dynamic>)
        .tryGetSuccess();
    final cashFlow = (results[3] as Result<CashFlowEntity, dynamic>)
        .tryGetSuccess();

    final prompt = buildAiFinancialAdvicePrompt(
      cashFlow: cashFlow,
      insights: insights,
      anomalies: anomalies ?? const [],
      runway: runway,
      currencyCode: settings.currencyCode,
    );

    final raw = await CcGeminiHelper.generateText(
      prompt: prompt,
      responseSchema: _buildResponseSchema(),
    );
    if (raw == null || raw.trim().isEmpty) return null;

    final sections = _parseSections(raw);
    if (sections.isEmpty) return null;

    return AiAdviceEntity(sections: sections, generatedAt: DateTime.now());
  }

  Schema _buildResponseSchema() {
    return Schema.object(
      properties: {
        'sections': Schema.array(
          items: Schema.object(
            properties: {
              'status': Schema.enumString(
                enumValues: ['good', 'normal', 'bad'],
                description:
                    'Tone of this section: good (positive/encouraging), '
                    'normal (neutral advice), or bad (warning/needs '
                    'attention).',
              ),
              'text': Schema.string(
                description:
                    'Short Vietnamese advice text for this section '
                    '(1-3 sentences), plain prose, no markdown.',
              ),
              'highlights': Schema.array(
                items: Schema.string(),
                maxItems: _maxHighlightsPerSection,
                description:
                    '1-$_maxHighlightsPerSection key words or phrases '
                    '(amounts, percentages, category names, key actions) '
                    'copied exactly, character for character, from the text '
                    'of this section, each at most 6 words. Empty array if '
                    'nothing stands out.',
              ),
            },
          ),
          minItems: 2,
          maxItems: 4,
          description: '2-4 distinct advice sections.',
        ),
      },
    );
  }

  /// Defensive JSON parsing, same pattern as `ParseBillImageUseCase`'s
  /// `_parseJsonResponse` — `responseSchema` constrains the shape but the
  /// raw string is still untrusted model output, so every field is
  /// validated before use and malformed entries are skipped rather than
  /// failing the whole response.
  List<AiAdviceSectionItem> _parseSections(String raw) {
    try {
      final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map || decoded['sections'] is! List) return const [];

      final sections = <AiAdviceSectionItem>[];
      for (final item in decoded['sections'] as List) {
        if (item is! Map) continue;
        final text = item['text'];
        if (text is! String || text.trim().isEmpty) continue;
        sections.add(
          AiAdviceSectionItem(
            status: _parseStatus(item['status']),
            text: text.trim(),
            highlights: _parseHighlights(item['highlights']),
          ),
        );
      }
      return sections;
    } catch (e) {
      'Failed to parse AI advice response: $e'.Log(
        'GenerateAiFinancialAdviceUseCase',
      );
      return const [];
    }
  }

  List<String> _parseHighlights(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<String>()
        .map((highlight) => highlight.trim())
        .where((highlight) => highlight.isNotEmpty)
        .take(_maxHighlightsPerSection)
        .toList();
  }

  AiAdviceSectionStatus _parseStatus(Object? raw) {
    switch (raw) {
      case 'good':
        return AiAdviceSectionStatus.good;
      case 'bad':
        return AiAdviceSectionStatus.bad;
      default:
        return AiAdviceSectionStatus.normal;
    }
  }
}
