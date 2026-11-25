import 'package:equatable/equatable.dart';

import 'ai_advice_section_status.dart';

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

