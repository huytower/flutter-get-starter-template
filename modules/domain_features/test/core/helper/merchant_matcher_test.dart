import 'package:domain_features/core/helper/merchant_matcher.dart';
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionEntity _expense(String id, String? note) => TransactionEntity(
  id: id,
  type: TransactionType.expense,
  amount: 50000,
  category: '',
  date: DateTime(2026, 10, 1),
  walletId: 'w',
  note: note,
);

void main() {
  group('MerchantMatcher', () {
    test('matches ignoring case and Vietnamese diacritics', () {
      final phucLong = _expense('1', 'Trà sữa Phúc Long');
      final matcher = MerchantMatcher([_expense('2', 'Grab đi làm'), phucLong]);

      expect(matcher.findBest('tra sua phuc long'), phucLong);
    });

    test('picks the most similar note', () {
      final coffee = _expense('1', 'cafe sua da highlands');
      final matcher = MerchantMatcher([_expense('2', 'tien dien'), coffee]);

      expect(matcher.findBest('cafe sua da'), coffee);
    });

    test('returns null when the query is too short', () {
      final matcher = MerchantMatcher([_expense('1', 'ab cd')]);

      expect(matcher.findBest('ab'), isNull);
    });

    test('returns null when nothing is similar enough', () {
      final matcher = MerchantMatcher([_expense('1', 'tien dien thang 9')]);

      expect(matcher.findBest('trà sữa phúc long'), isNull);
    });

    test('skips candidates without a note', () {
      final matcher = MerchantMatcher([
        _expense('1', null),
        _expense('2', '   '),
      ]);

      expect(matcher.findBest('trà sữa phúc long'), isNull);
    });

    test('returns the right entry when note-less ones come first', () {
      final phucLong = _expense('3', 'Trà sữa Phúc Long');
      final matcher = MerchantMatcher([
        _expense('1', null),
        _expense('2', '   '),
        phucLong,
      ]);

      expect(matcher.findBest('tra sua phuc long'), phucLong);
    });

    test('treats a score equal to the threshold as a match', () {
      final note = _expense('1', 'abd');
      final matcher = MerchantMatcher([note]);

      expect(matcher.findBest('abc'), note);
      expect(matcher.findBest('abc', threshold: 0.51), isNull);
    });

    test('returns null when there are no candidates', () {
      expect(MerchantMatcher(const []).findBest('trà sữa phúc long'), isNull);
    });
  });
}
