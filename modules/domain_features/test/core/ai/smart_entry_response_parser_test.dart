import 'dart:convert';

import 'package:domain_features/core/ai/smart_entry_context.dart';
import 'package:domain_features/core/ai/smart_entry_response_parser.dart';
import 'package:domain_features/core/ai/smart_entry_schema.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:domain_features/features/transaction/domain/entities/parsed_transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

SmartEntryContext _context({
  String primary = 'VND',
  List<String> types = const [CategoryType.expense],
}) => SmartEntryContext(
  types: types,
  categories: const [
    (id: 'food', label: 'Food', type: CategoryType.expense),
    (id: 'fuel', label: 'Fuel', type: CategoryType.expense),
    (id: 'salary', label: 'Salary', type: CategoryType.income),
  ],
  wallets: const [(id: 'w1', name: 'Cash')],
  currency: CurrencyCatalog.getDefinition(primary),
  language: 'English',
  today: DateTime(2026, 10, 26),
);

Map<String, Object?> _row({
  Object? amount = 100,
  Object? currencyCode,
  Object? categoryId = 'food',
  Object? walletId,
  Object? date,
  Object? note,
  Object? type,
}) => {
  'type': type,
  'amount': amount,
  'currencyCode': currencyCode,
  'categoryId': categoryId,
  'walletId': walletId,
  'date': date,
  'note': note,
};

String _json(List<Map<String, Object?>> rows, {String? documentKind}) =>
    jsonEncode({'documentKind': ?documentKind, 'transactions': rows});

List<RawParsedTransaction>? _parse(
  String raw, {
  SmartEntryContext? context,
  int max = 20,
}) => SmartEntryResponseParser.parse(
  raw,
  context ?? _context(),
  maxTransactions: max,
);

void main() {
  final codes = CurrencyCatalog.definitions.map((d) => d.code).toList();

  RawParsedTransaction only(String raw, String primary) =>
      _parse(raw, context: _context(primary: primary))!.single;

  group('structure', () {
    test('keeps every row in the order the model returned them', () {
      final parsed = _parse(
        _json([_row(amount: 10), _row(amount: 20), _row(amount: 30)]),
      );

      expect(parsed!.map((e) => e.entity.amount), [10, 20, 30]);
    });

    test('an empty transactions array is a valid empty result', () {
      expect(_parse(_json(const [])), isEmpty);
    });

    test('a not_financial document yields nothing even if rows came back', () {
      final parsed = _parse(
        _json([_row()], documentKind: SmartEntrySchema.kindNotFinancial),
      );

      expect(parsed, isEmpty);
    });

    test('receipt and list kinds keep their rows', () {
      for (final kind in [
        SmartEntrySchema.kindSingleReceipt,
        SmartEntrySchema.kindTransactionList,
      ]) {
        expect(_parse(_json([_row()], documentKind: kind)), hasLength(1));
      }
    });

    test('drops a row with nothing usable but keeps the others', () {
      final parsed = _parse(
        _json([_row(amount: null, categoryId: null), _row(amount: 5)]),
      );

      expect(parsed, hasLength(1));
      expect(parsed!.single.entity.amount, 5);
    });

    test('skips entries that are not objects', () {
      final raw = jsonEncode({
        'transactions': [1, 'x', null, _row(amount: 7)],
      });

      expect(_parse(raw)!.single.entity.amount, 7);
    });

    test('stops at the requested maximum', () {
      final parsed = _parse(
        _json([for (var i = 1; i <= 5; i++) _row(amount: i)]),
        max: 3,
      );

      expect(parsed!.map((e) => e.entity.amount), [1, 2, 3]);
    });

    test(
      'keeps identical rows, since two equal purchases can both be real',
      () {
        final parsed = _parse(
          _json([_row(note: 'Coffee'), _row(note: 'Coffee')]),
        );

        expect(parsed, hasLength(2));
      },
    );

    test('strips markdown fences around the JSON', () {
      final parsed = _parse('```json\n${_json([_row(amount: 70000)])}\n```');

      expect(parsed!.single.entity.amount, 70000);
    });

    test('is null for malformed JSON or a missing transactions list', () {
      expect(_parse('not json'), isNull);
      expect(_parse(jsonEncode({'foo': 1})), isNull);
      expect(_parse(jsonEncode({'transactions': 'nope'})), isNull);
      expect(_parse(jsonEncode([1, 2])), isNull);
    });
  });

  group('per-field tolerance', () {
    test('drops an unoffered category and a future date, keeps the rest', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final parsed = _parse(
        _json([
          _row(
            categoryId: 'unknown',
            date: tomorrow.toIso8601String().substring(0, 10),
          ),
        ]),
      )!.single.entity;

      expect(parsed.categoryId, isNull);
      expect(parsed.date, isNull);
      expect(parsed.amount, 100);
    });

    test('keeps a valid past date, offered wallet and trimmed note', () {
      final parsed = _parse(
        _json([_row(date: '2026-10-01', walletId: 'w1', note: '  Pho  ')]),
      )!.single.entity;

      expect(parsed.date, DateTime(2026, 10, 1));
      expect(parsed.walletId, 'w1');
      expect(parsed.note, 'Pho');
    });

    test('drops an unoffered wallet and a blank note', () {
      final parsed = _parse(
        _json([_row(walletId: 'nope', note: '   ')]),
      )!.single.entity;

      expect(parsed.walletId, isNull);
      expect(parsed.note, isNull);
    });

    test('one bad field never takes the rest of its row down', () {
      final parsed = _parse(
        _json([_row(amount: 'lots', categoryId: 'food', date: 'yesterday')]),
      )!.single.entity;

      expect(parsed.amount, isNull);
      expect(parsed.categoryId, 'food');
      expect(parsed.date, isNull);
    });
  });

  group('mixed income and expense', () {
    final mixed = _context(
      types: const [CategoryType.expense, CategoryType.income],
    );

    List<ParsedTransactionEntity> parse(List<Map<String, Object?>> rows) =>
        _parse(_json(rows), context: mixed)!.map((e) => e.entity).toList();

    test('takes each row type from the model', () {
      final rows = parse([
        _row(type: 'expense', categoryId: 'food'),
        _row(type: 'income', categoryId: 'salary'),
      ]);

      expect(rows.map((e) => e.type), ['expense', 'income']);
      expect(rows.map((e) => e.categoryId), ['food', 'salary']);
    });

    test('drops a category that belongs to the other type', () {
      final rows = parse([_row(type: 'income', categoryId: 'food')]);

      expect(rows.single.type, 'income');
      expect(rows.single.categoryId, isNull);
    });

    test(
      'derives the type from the category when the model type is unusable',
      () {
        for (final bad in [null, 'transfer', 7]) {
          final rows = parse([_row(type: bad, categoryId: 'salary')]);

          expect(rows.single.type, 'income', reason: '$bad');
          expect(rows.single.categoryId, 'salary', reason: '$bad');
        }
      },
    );

    test('falls back to the host default type when nothing identifies it', () {
      final rows = parse([_row(type: null, categoryId: null)]);

      expect(rows.single.type, CategoryType.expense);
    });

    test('a single-type scope leaves the type to the host', () {
      final entity = _parse(_json([_row()]))!.single.entity;

      expect(entity.type, isNull);
    });
  });

  group('currency', () {
    for (final primary in codes) {
      test('keeps the amount when the stated currency is $primary itself', () {
        final parsed = only(
          _json([_row(amount: 1500, currencyCode: primary)]),
          primary,
        );

        expect(parsed.foreignCurrencyCode, isNull);
        expect(parsed.entity.amount, 1500);
      });

      test('keeps the amount when no currency is stated ($primary)', () {
        final parsed = only(_json([_row(amount: 1500)]), primary);

        expect(parsed.foreignCurrencyCode, isNull);
        expect(parsed.entity.amount, 1500);
      });

      test(
        'hands any other supported currency over for conversion ($primary)',
        () {
          for (final other in codes.where((c) => c != primary)) {
            final parsed = only(
              _json([_row(amount: 1500, currencyCode: other)]),
              primary,
            );

            expect(
              parsed.foreignCurrencyCode,
              other,
              reason: '$other/$primary',
            );
            expect(parsed.foreignAmount, 1500, reason: '$other/$primary');
            expect(parsed.entity.amount, isNull, reason: '$other/$primary');
          }
        },
      );
    }

    test('hands an unsupported currency over too', () {
      for (final unsupported in ['GBP', 'THB', 'SGD']) {
        final parsed = only(
          _json([_row(amount: 20, currencyCode: unsupported)]),
          'VND',
        );

        expect(parsed.foreignCurrencyCode, unsupported);
        expect(parsed.foreignAmount, 20);
        expect(parsed.entity.amount, isNull);
      }
    });

    test('converts each row on its own currency', () {
      final parsed = _parse(
        _json([_row(amount: 5, currencyCode: 'USD'), _row(amount: 70000)]),
      )!;

      expect(parsed.map((e) => e.foreignCurrencyCode), ['USD', null]);
      expect(parsed.map((e) => e.entity.amount), [null, 70000]);
    });

    test('keeps the foreign amount unrounded for conversion', () {
      final parsed = only(
        _json([_row(amount: 12.5, currencyCode: 'USD')]),
        'VND',
      );

      expect(parsed.foreignAmount, 12.5);
    });

    test('keeps a sub-unit foreign amount that rounds to zero', () {
      final parsed = only(
        _json([_row(amount: 0.4, currencyCode: 'USD')]),
        'VND',
      );

      expect(parsed.foreignAmount, 0.4);
    });

    test('has no foreign amount when it is zero or negative', () {
      for (final amount in [0, -5]) {
        final parsed = _parse(
          _json([_row(amount: amount, currencyCode: 'USD')]),
        )!;

        expect(parsed, hasLength(1), reason: '$amount');
        expect(parsed.single.foreignCurrencyCode, 'USD', reason: '$amount');
        expect(parsed.single.foreignAmount, isNull, reason: '$amount');
      }
    });

    test('normalises case and whitespace on the stated code', () {
      final same = only(
        _json([_row(amount: 12, currencyCode: ' usd ')]),
        'USD',
      );
      final other = only(
        _json([_row(amount: 12, currencyCode: ' usd ')]),
        'VND',
      );

      expect(same.foreignCurrencyCode, isNull);
      expect(other.foreignCurrencyCode, 'USD');
    });

    test('ignores placeholder values that are not an ISO code', () {
      for (final placeholder in ['', 'null', 'N/A', 'none', 'đ', 42]) {
        final parsed = only(
          _json([_row(amount: 50000, currencyCode: placeholder)]),
          'VND',
        );

        expect(parsed.foreignCurrencyCode, isNull, reason: '$placeholder');
        expect(parsed.entity.amount, 50000, reason: '$placeholder');
      }
    });

    test('keeps the other fields when the currency is foreign', () {
      final parsed = only(
        _json([_row(amount: 50, currencyCode: 'USD', categoryId: 'food')]),
        'VND',
      );

      expect(parsed.entity.amount, isNull);
      expect(parsed.entity.categoryId, 'food');
    });

    test('rounds decimals to whole units', () {
      expect(only(_json([_row(amount: 12.4)]), 'USD').entity.amount, 12);
      expect(only(_json([_row(amount: 12.6)]), 'USD').entity.amount, 13);
    });

    test('treats an amount that rounds to zero as missing', () {
      for (final amount in [0.4, 0, -5]) {
        expect(
          only(_json([_row(amount: amount)]), 'USD').entity.amount,
          isNull,
          reason: '$amount',
        );
      }
    });
  });
}
