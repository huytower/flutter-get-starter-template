import 'package:domain_features/core/helper/ai_advice_highlight_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<String> highlighted(List<AiAdviceTextSegment> segments) => [
    for (final s in segments)
      if (s.isHighlighted) s.text,
  ];

  String joined(List<AiAdviceTextSegment> segments) =>
      segments.map((s) => s.text).join();

  group('splitAiAdviceHighlights', () {
    test('returns one plain segment when there are no highlights', () {
      final result = splitAiAdviceHighlights('Chi tiêu ổn định', const []);

      expect(result, [(text: 'Chi tiêu ổn định', isHighlighted: false)]);
    });

    test('returns nothing for empty text', () {
      expect(splitAiAdviceHighlights('', const ['x']), isEmpty);
    });

    test('splits around a phrase in the middle', () {
      final result = splitAiAdviceHighlights(
        'Bạn đã chi 1.500.000đ cho ăn uống',
        const ['1.500.000đ'],
      );

      expect(result, [
        (text: 'Bạn đã chi ', isHighlighted: false),
        (text: '1.500.000đ', isHighlighted: true),
        (text: ' cho ăn uống', isHighlighted: false),
      ]);
    });

    test('produces no empty segments at the start or end', () {
      final result = splitAiAdviceHighlights('Thâm hụt tháng này', const [
        'Thâm hụt',
        'tháng này',
      ]);

      expect(result, [
        (text: 'Thâm hụt', isHighlighted: true),
        (text: ' ', isHighlighted: false),
        (text: 'tháng này', isHighlighted: true),
      ]);
    });

    test('matches case-insensitively but keeps the original casing', () {
      final result = splitAiAdviceHighlights(
        'Hãy giảm Ăn Uống tuần sau',
        const ['ăn uống'],
      );

      expect(highlighted(result), ['Ăn Uống']);
      expect(joined(result), 'Hãy giảm Ăn Uống tuần sau');
    });

    test('ignores phrases that are not in the text, blank, or whitespace', () {
      final result = splitAiAdviceHighlights('Chi tiêu ổn định', const [
        'không có',
        '',
        '   ',
      ]);

      expect(result, [(text: 'Chi tiêu ổn định', isHighlighted: false)]);
    });

    test('merges overlapping and duplicate phrases', () {
      final result = splitAiAdviceHighlights(
        'Giảm chi tiêu ăn uống ngay',
        const ['chi tiêu ăn', 'ăn uống', 'ăn uống'],
      );

      expect(highlighted(result), ['chi tiêu ăn uống']);
      expect(joined(result), 'Giảm chi tiêu ăn uống ngay');
    });

    test('highlights only the first occurrence of a phrase', () {
      final result = splitAiAdviceHighlights('30% rồi lại 30%', const ['30%']);

      expect(highlighted(result), ['30%']);
      expect(joined(result), '30% rồi lại 30%');
    });

    test('keeps the full text intact for any input', () {
      const text = 'Thu nhập 15tr, chi 18tr: thâm hụt 3tr mỗi tháng';
      final result = splitAiAdviceHighlights(text, const [
        '15tr',
        'thâm hụt 3tr',
        'tháng',
      ]);

      expect(joined(result), text);
    });
  });
}
