import 'package:domain_features/core/helper/monthly_bill_suggestion_helper.dart';
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionEntity _txn(
  DateTime date, {
  String categoryId = 'salary',
  String category = '',
}) => TransactionEntity(
  id: '${date.microsecondsSinceEpoch}_$categoryId',
  type: TransactionType.income,
  amount: 1000,
  category: category,
  categoryId: categoryId,
  date: date,
  walletId: 'w',
);

void main() {
  final now = DateTime(2026, 10, 18);

  group('findMonthlyBillMatch', () {
    test('matches last month within the day tolerance', () {
      final lastMonth = _txn(DateTime(2026, 9, 17));

      expect(
        findMonthlyBillMatch(now: now, candidates: [lastMonth]),
        lastMonth,
      );
    });

    test('ignores last-month entries outside the day tolerance', () {
      final result = findMonthlyBillMatch(
        now: now,
        candidates: [_txn(DateTime(2026, 9, 5))],
      );

      expect(result, isNull);
    });

    test('ignores entries older than last month', () {
      final result = findMonthlyBillMatch(
        now: now,
        candidates: [_txn(DateTime(2026, 8, 18))],
      );

      expect(result, isNull);
    });

    test('prefers the entry closest to today', () {
      final far = _txn(DateTime(2026, 9, 15), categoryId: 'a');
      final near = _txn(DateTime(2026, 9, 19), categoryId: 'b');

      expect(findMonthlyBillMatch(now: now, candidates: [far, near]), near);
    });

    test('projects a missing day onto the last day of a short month', () {
      final shortMonthNow = DateTime(2026, 2, 27);
      final endOfJanuary = _txn(DateTime(2026, 1, 31));

      expect(
        findMonthlyBillMatch(now: shortMonthNow, candidates: [endOfJanuary]),
        endOfJanuary,
      );
    });

    test('hides the suggestion once the category is recorded this month', () {
      final result = findMonthlyBillMatch(
        now: now,
        candidates: [_txn(DateTime(2026, 9, 17)), _txn(DateTime(2026, 10, 5))],
      );

      expect(result, isNull);
    });

    test('keeps the suggestion when only another category is recorded', () {
      final salary = _txn(DateTime(2026, 9, 17));

      final result = findMonthlyBillMatch(
        now: now,
        candidates: [
          salary,
          _txn(DateTime(2026, 10, 5), categoryId: 'bonus'),
        ],
      );

      expect(result, salary);
    });

    test('compares the category label when there is no category id', () {
      final result = findMonthlyBillMatch(
        now: now,
        candidates: [
          _txn(DateTime(2026, 9, 17), categoryId: '', category: 'Rent'),
          _txn(DateTime(2026, 10, 5), categoryId: '', category: 'Rent'),
        ],
      );

      expect(result, isNull);
    });

    test('does not count next-month entries as recorded this month', () {
      final salary = _txn(DateTime(2026, 9, 17));

      final result = findMonthlyBillMatch(
        now: now,
        candidates: [salary, _txn(DateTime(2026, 11, 2))],
      );

      expect(result, salary);
    });

    test('counts an entry dated later this month as already recorded', () {
      final result = findMonthlyBillMatch(
        now: now,
        candidates: [_txn(DateTime(2026, 9, 17)), _txn(DateTime(2026, 10, 25))],
      );

      expect(result, isNull);
    });

    test('keeps the first candidate when two are equally close', () {
      final earlier = _txn(DateTime(2026, 9, 16), categoryId: 'a');
      final later = _txn(DateTime(2026, 9, 20), categoryId: 'b');

      expect(
        findMonthlyBillMatch(now: now, candidates: [earlier, later]),
        earlier,
      );
      expect(
        findMonthlyBillMatch(now: now, candidates: [later, earlier]),
        later,
      );
    });

    test('looks back into December from January', () {
      final december = _txn(DateTime(2025, 12, 9));

      expect(
        findMonthlyBillMatch(
          now: DateTime(2026, 1, 10),
          candidates: [december],
        ),
        december,
      );
    });

    test('hides a legacy label-only entry once the app recorded the id', () {
      final result = findMonthlyBillMatch(
        now: now,
        candidates: [
          _txn(DateTime(2026, 9, 17), categoryId: '', category: 'Lương'),
          _txn(DateTime(2026, 10, 5), categoryId: 'salary', category: 'Lương'),
        ],
      );

      expect(result, isNull);
    });

    test('hides an app entry once a legacy label-only entry is recorded', () {
      final result = findMonthlyBillMatch(
        now: now,
        candidates: [
          _txn(DateTime(2026, 9, 17), categoryId: 'salary', category: 'Lương'),
          _txn(DateTime(2026, 10, 5), categoryId: '', category: 'Lương'),
        ],
      );

      expect(result, isNull);
    });

    test('does not treat uncategorized entries as the same category', () {
      final lastMonth = _txn(DateTime(2026, 9, 17), categoryId: '');

      final result = findMonthlyBillMatch(
        now: now,
        candidates: [
          lastMonth,
          _txn(DateTime(2026, 10, 5), categoryId: ''),
        ],
      );

      expect(result, lastMonth);
    });
  });

  group('monthlyBillWindow', () {
    test('spans the start of last month to the end of this month', () {
      final window = monthlyBillWindow(now);

      expect(window.start, DateTime(2026, 9, 1));
      expect(window.end, DateTime(2026, 10, 31, 23, 59, 59, 999, 999));
    });

    test('ends strictly before the first instant of next month', () {
      final window = monthlyBillWindow(now);

      expect(window.end.isBefore(DateTime(2026, 11, 1)), isTrue);
      expect(
        DateTime(2026, 11, 1).difference(window.end),
        const Duration(microseconds: 1),
      );
    });

    test('rolls back across the year boundary in January', () {
      final window = monthlyBillWindow(DateTime(2026, 1, 10));

      expect(window.start, DateTime(2025, 12, 1));
      expect(window.end, DateTime(2026, 1, 31, 23, 59, 59, 999, 999));
    });
  });
}
