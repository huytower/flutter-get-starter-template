import 'package:equatable/equatable.dart';

/// Qualitative tone of one [AiAdviceSectionItem], driving its color in the
/// UI — mirrors the good/normal/bad severity language already used for
/// budget pacing/penalty warnings elsewhere in Report.
enum AiAdviceSectionStatus { good, normal, bad }

/// One self-contained piece of advice (e.g. anomaly remark, income
/// strategy, spending tip), tagged with the tone it should be displayed in.
class AiAdviceSectionItem extends Equatable {
  final AiAdviceSectionStatus status;
  final String text;
  final List<String> highlights;

  const AiAdviceSectionItem({
    required this.status,
    required this.text,
    this.highlights = const [],
  });

  @override
  List<Object?> get props => [status, text, highlights];
}

/// Phase 3.8 — a cloud-LLM-generated narrative combining "AI Actions for
/// Budget Issues" (income-increase suggestions, anomaly review) and
/// "Spending Optimization" (habit warnings, saving encouragement), broken
/// into discrete, status-tagged [sections] rather than one flat paragraph.
/// Unlike [BudgetInsightsEntity], this is never auto-computed — it's only
/// ever produced by an explicit user-triggered cloud call, held in memory
/// for the current app session only (no disk persistence).
class AiAdviceEntity extends Equatable {
  final List<AiAdviceSectionItem> sections;
  final DateTime generatedAt;

  const AiAdviceEntity({required this.sections, required this.generatedAt});

  @override
  List<Object?> get props => [sections, generatedAt];
}
