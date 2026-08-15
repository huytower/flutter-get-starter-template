import 'package:equatable/equatable.dart';

/// Phase 3.8 — a cloud-LLM-generated narrative combining "AI Actions for
/// Budget Issues" (income-increase suggestions, anomaly review) and
/// "Spending Optimization" (habit warnings, saving encouragement) into one
/// piece of Vietnamese prose. Unlike [BudgetInsightsEntity], this is never
/// auto-computed — it's only ever produced by an explicit user-triggered
/// cloud call, then cached locally until the next explicit refresh.
class AiAdviceEntity extends Equatable {
  final String text;
  final DateTime generatedAt;

  const AiAdviceEntity({required this.text, required this.generatedAt});

  @override
  List<Object?> get props => [text, generatedAt];
}
