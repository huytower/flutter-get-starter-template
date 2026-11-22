typedef AiAdviceTextSegment = ({String text, bool isHighlighted});

List<AiAdviceTextSegment> splitAiAdviceHighlights(
  String text,
  List<String> highlights,
) {
  if (text.isEmpty) return const [];

  final folded = text.toLowerCase();
  final isFoldable = folded.length == text.length;
  final searchable = isFoldable ? folded : text;

  final ranges = <(int, int)>[];
  for (final highlight in highlights) {
    final trimmed = highlight.trim();
    if (trimmed.isEmpty) continue;
    final needle = isFoldable ? trimmed.toLowerCase() : trimmed;
    final start = searchable.indexOf(needle);
    if (start < 0) continue;
    ranges.add((start, start + needle.length));
  }
  if (ranges.isEmpty) return [(text: text, isHighlighted: false)];

  ranges.sort((a, b) => a.$1.compareTo(b.$1));
  final merged = <(int, int)>[ranges.first];
  for (final range in ranges.skip(1)) {
    final last = merged.last;
    if (range.$1 <= last.$2) {
      merged[merged.length - 1] = (
        last.$1,
        range.$2 > last.$2 ? range.$2 : last.$2,
      );
    } else {
      merged.add(range);
    }
  }

  final segments = <AiAdviceTextSegment>[];
  var cursor = 0;
  for (final range in merged) {
    if (range.$1 > cursor) {
      segments.add((
        text: text.substring(cursor, range.$1),
        isHighlighted: false,
      ));
    }
    segments.add((
      text: text.substring(range.$1, range.$2),
      isHighlighted: true,
    ));
    cursor = range.$2;
  }
  if (cursor < text.length) {
    segments.add((text: text.substring(cursor), isHighlighted: false));
  }
  return segments;
}
