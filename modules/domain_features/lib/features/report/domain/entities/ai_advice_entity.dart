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

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'text': text,
    'highlights': highlights,
  };

  factory AiAdviceSectionItem.fromJson(Map<String, dynamic> json) =>
      AiAdviceSectionItem(
        status: AiAdviceSectionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => AiAdviceSectionStatus.normal,
        ),
        text: json['text'] as String? ?? '',
        highlights:
            (json['highlights'] as List?)?.map((e) => '$e').toList() ??
            const [],
      );

  @override
  List<Object?> get props => [status, text, highlights];
}

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
