import 'package:equatable/equatable.dart';

import 'ai_advice_section_item.dart';

export 'ai_advice_section_item.dart';
export 'ai_advice_section_status.dart';

/// Phase 3.8 — a cloud-LLM-generated narrative combining "AI Actions for
/// Budget Issues" (income-increase suggestions, anomaly review) and
/// "Spending Optimization" (habit warnings, saving encouragement), broken
/// into discrete, status-tagged [sections] rather than one flat paragraph.
class AiAdviceEntity extends Equatable {
  final List<AiAdviceSectionItem> sections;
  final DateTime generatedAt;

  const AiAdviceEntity({required this.sections, required this.generatedAt});

  Map<String, dynamic> toJson() => {
    'sections': sections.map((s) => s.toJson()).toList(),
    'generatedAt': generatedAt.toIso8601String(),
  };

  factory AiAdviceEntity.fromJson(Map<String, dynamic> json) => AiAdviceEntity(
    sections:
        (json['sections'] as List?)
            ?.map(
              (s) => AiAdviceSectionItem.fromJson(
                Map<String, dynamic>.from(s as Map),
              ),
            )
            .toList() ??
        const [],
    generatedAt:
        DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
        DateTime.now(),
  );

  @override
  List<Object?> get props => [sections, generatedAt];
}
