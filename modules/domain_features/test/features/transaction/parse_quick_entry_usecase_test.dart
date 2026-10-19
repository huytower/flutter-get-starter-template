import 'dart:convert';

import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_types.dart';
import 'package:domain_features/core/helper/quick_entry_parse_result.dart';
import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:domain_features/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:domain_features/features/transaction/domain/usecases/parse_quick_entry_usecase.dart';
import 'package:domain_features/features/wallet/domain/entities/wallet_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

class _FakeGetCategories implements GetCategoriesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRateRepository implements ExchangeRateRepository {
  _FakeRateRepository({
    this.provenance = RateProvenance.network,
    this.failure,
    this.throws = false,
  });

  static const Map<String, double> _perUsd = {
    'USD': 1.0,
    'VND': 25000.0,
    'EUR': 0.9,
    'JPY': 150.0,
    'KRW': 1350.0,
    'CNY': 7.0,
  };

  final RateProvenance provenance;
  final ExchangeRateFailure? failure;
  final bool throws;
  int calls = 0;

  @override
  Future<Result<ExchangeRateResult, ExchangeRateFailure>> getExchangeRates({
    required String baseCurrency,
    required List<String> quoteCurrencies,
    DateTime? date,
  }) async {
    calls++;
    if (throws) throw StateError('rate lookup failed');
    if (failure != null) return Error(failure!);
    final base = _perUsd[baseCurrency]!;
    return Success(
      ExchangeRateResult(
        table: ExchangeRateTable(
          baseCurrency: baseCurrency,
          rates: {for (final q in quoteCurrencies) q: _perUsd[q]! / base},
          effectiveDate: DateTime(2026, 10, 19),
          fetchedAt: DateTime(2026, 10, 19),
          provider: 'fake',
        ),
        provenance: provenance,
      ),
    );
  }
}

const _food = CategoryEntity(
  id: 'food',
  nameKey: 'category.food',
  iconCode: 0,
  groupId: 'g',
);

final _wallet = WalletEntity(
  id: 'w1',
  name: 'Cash',
  balance: 0,
  iconCode: 0,
  type: WalletType.cash,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

String _json({Object? amount, Object? currencyCode, String? categoryId}) =>
    jsonEncode({
      'amount': amount,
      'currencyCode': currencyCode,
      'categoryId': categoryId,
    });

ParseQuickEntryUseCase _useCaseWith(_FakeRateRepository repository) =>
    ParseQuickEntryUseCase(
      _FakeGetCategories(),
      CurrencyConversionService(repository),
    );

void main() {
  final useCase = _useCaseWith(_FakeRateRepository());
  final codes = CurrencyCatalog.definitions.map((d) => d.code).toList();

  ({
    QuickEntryParseResult result,
    String? foreignCurrencyCode,
    num? foreignAmount,
  })?
  parse(String raw, String primary) => useCase.parseJsonResponse(
    raw,
    validCatIds: {'food'},
    validWalletIds: {'w1'},
    currency: CurrencyCatalog.getDefinition(primary),
  );

  group('currencyPromptSentence', () {
    for (final def in CurrencyCatalog.definitions) {
      test('names ${def.code} as the primary and default currency', () {
        final sentence = useCase.currencyPromptSentence(def);

        expect(sentence, contains('primary currency is ${def.code} '));
        expect(
          sentence,
          contains('no currency written or shown are in ${def.code}.'),
        );
      });
    }

    test('asks for the amount unconverted, in the currency as written', () {
      final sentence = useCase.currencyPromptSentence(
        CurrencyCatalog.getDefinition('VND'),
      );

      expect(sentence, contains('exactly as written'));
      expect(sentence, contains('never converting it to another currency'));
      expect(sentence, isNot(contains('whole VND units')));
    });

    test('resolves ambiguous symbols instead of defaulting to primary', () {
      final sentence = useCase.currencyPromptSentence(
        CurrencyCatalog.getDefinition('VND'),
      );

      expect(sentence, contains(r'$ is USD'));
      expect(sentence, contains('€ is EUR'));
      expect(sentence, contains('₩ is KRW'));
      expect(sentence, contains('¥ is VND when that is JPY or CNY'));
      expect(sentence, contains('otherwise JPY'));
    });

    test('covers CJK and Vietnamese magnitude shorthand', () {
      final sentence = useCase.currencyPromptSentence(
        CurrencyCatalog.getDefinition('JPY'),
      );

      for (final token in ['nghìn', 'triệu', '千', '천', '万', '만', '億']) {
        expect(sentence, contains(token));
      }
    });
  });

  group('resolveLanguageName', () {
    test('maps the supported app languages', () {
      expect(useCase.resolveLanguageName('vi'), 'Vietnamese');
      expect(useCase.resolveLanguageName('en'), 'English');
      expect(useCase.resolveLanguageName('EN'), 'English');
    });

    test('falls back to the app default language when none is given', () {
      expect(useCase.resolveLanguageName(null), 'Vietnamese');
    });

    test('keeps an unmapped language code as is', () {
      expect(useCase.resolveLanguageName('ja'), 'ja');
    });
  });

  group('noteLanguagePromptSentence', () {
    test('pins the note language but keeps proper names', () {
      final sentence = useCase.noteLanguagePromptSentence('English');

      expect(sentence, contains('"note" in English'));
      expect(sentence, contains('whatever language the input is in'));
      expect(sentence, contains('merchant, brand and product names'));
    });
  });

  group('buildResponseSchema', () {
    Map<dynamic, dynamic> properties(String primary, String language) {
      final schema = useCase.buildResponseSchema(
        [_food],
        [_wallet],
        CurrencyCatalog.getDefinition(primary),
        language,
      );
      return schema.toJson()['properties'] as Map;
    }

    test(
      'currencyCode is a free string so unsupported codes can be flagged',
      () {
        final currency = properties('USD', 'English')['currencyCode'] as Map;

        expect(currency['type'], 'STRING');
        expect(currency.containsKey('enum'), isFalse);
        expect(currency['nullable'], isTrue);
      },
    );

    test('amount is unconverted and names the primary as the default', () {
      final amount = properties('KRW', 'English')['amount'] as Map;

      expect(amount['description'], contains('KRW when none is stated'));
      expect(amount['description'], contains('never converted'));
    });

    test('note follows the requested language', () {
      final english = properties('USD', 'English')['note'] as Map;
      final vietnamese = properties('USD', 'Vietnamese')['note'] as Map;

      expect(english['description'], contains('in English'));
      expect(vietnamese['description'], contains('in Vietnamese'));
      expect(english['description'], isNot(contains('Vietnamese')));
    });
  });

  group('buildBatchResponseSchema', () {
    Map<dynamic, dynamic> items(int count) {
      final schema = useCase.buildBatchResponseSchema(
        [_food],
        [_wallet],
        CurrencyCatalog.getDefinition('VND'),
        'English',
        count,
      );
      final properties = schema.toJson()['properties'] as Map;
      return properties['items'] as Map;
    }

    test('pins the array length to the image count', () {
      final array = items(3);

      expect(array['type'], 'ARRAY');
      expect(array['minItems'], 3);
      expect(array['maxItems'], 3);
    });

    test('each entry carries a bounded imageIndex plus the item fields', () {
      final entry = (items(4)['items'] as Map)['properties'] as Map;

      final index = entry['imageIndex'] as Map;
      expect(index['type'], 'INTEGER');
      expect(index['minimum'], 1);
      expect(index['maximum'], 4);
      for (final field in [
        'amount',
        'currencyCode',
        'categoryId',
        'walletId',
        'date',
        'note',
      ]) {
        expect(entry.containsKey(field), isTrue, reason: field);
      }
    });
  });

  group('parseBatchJsonResponse', () {
    List<
      ({
        QuickEntryParseResult result,
        String? foreignCurrencyCode,
        num? foreignAmount,
      })?
    >?
    parseBatch(String raw, {int count = 3, String primary = 'VND'}) =>
        useCase.parseBatchJsonResponse(
          raw,
          imageCount: count,
          validCatIds: {'food'},
          validWalletIds: {'w1'},
          currency: CurrencyCatalog.getDefinition(primary),
        );

    String batchJson(List<Map<String, Object?>> items) =>
        jsonEncode({'items': items});

    Map<String, Object?> entry(
      Object? index, {
      Object? amount = 100,
      String? categoryId = 'food',
      Object? currencyCode,
      String? date,
    }) => {
      'imageIndex': index,
      'amount': amount,
      'categoryId': categoryId,
      'currencyCode': currencyCode,
      'date': date,
    };

    test('maps entries to their image slot whatever order they arrive in', () {
      final parsed = parseBatch(
        batchJson([
          entry(3, amount: 30),
          entry(1, amount: 10),
          entry(2, amount: 20),
        ]),
      );

      expect(parsed!.map((e) => e!.result.amount), [10, 20, 30]);
    });

    test('leaves a slot null when the model skipped that image', () {
      final parsed = parseBatch(batchJson([entry(1), entry(3)]));

      expect(parsed!.length, 3);
      expect(parsed[1], isNull);
    });

    test('ignores out-of-range and non-integer image indexes', () {
      final parsed = parseBatch(
        batchJson([entry(0), entry(4), entry('2'), entry(null), entry(1)]),
      );

      expect(parsed![0], isNotNull);
      expect(parsed[1], isNull);
      expect(parsed[2], isNull);
    });

    test('treats a duplicated image index as ambiguous for that image', () {
      final parsed = parseBatch(
        batchJson([entry(1, amount: 10), entry(1, amount: 99), entry(2)]),
      );

      expect(parsed![0], isNull);
      expect(parsed[1], isNotNull);
    });

    test('drops an unoffered category and a future date per item', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final parsed = parseBatch(
        batchJson([
          entry(
            1,
            categoryId: 'unknown',
            date: tomorrow.toIso8601String().substring(0, 10),
          ),
        ]),
        count: 1,
      );

      expect(parsed![0]!.result.categoryId, isNull);
      expect(parsed[0]!.result.date, isNull);
      expect(parsed[0]!.result.amount, 100);
    });

    test('hands a foreign-currency item over for conversion', () {
      final parsed = parseBatch(
        batchJson([entry(1, amount: 12.5, currencyCode: 'USD')]),
        count: 1,
      );

      expect(parsed![0]!.foreignCurrencyCode, 'USD');
      expect(parsed[0]!.foreignAmount, 12.5);
      expect(parsed[0]!.result.amount, isNull);
    });

    test('strips markdown fences around the JSON', () {
      final parsed = parseBatch(
        '```json\n${batchJson([entry(1)])}\n```',
        count: 1,
      );

      expect(parsed![0]!.result.amount, 100);
    });

    test('returns null for malformed JSON or a missing items list', () {
      expect(parseBatch('not json'), isNull);
      expect(parseBatch(jsonEncode({'foo': 1})), isNull);
      expect(parseBatch(jsonEncode({'items': 'nope'})), isNull);
      expect(parseBatch(jsonEncode([1, 2])), isNull);
    });
  });

  group('finalizeBatchItem', () {
    ParsedCloudItem item({
      int? amount,
      String? categoryId,
      String? foreignCode,
      num? foreignAmount,
    }) => (
      result: QuickEntryParseResult(amount: amount, categoryId: categoryId),
      foreignCurrencyCode: foreignCode,
      foreignAmount: foreignAmount,
    );

    Future<QuickEntryParseResult?> finalize(
      ParsedCloudItem? parsed, {
      _FakeRateRepository? repository,
    }) => _useCaseWith(
      repository ?? _FakeRateRepository(),
    ).finalizeBatchItem(parsed, CurrencyCatalog.getDefinition('VND'));

    test('is null for an image the model skipped', () async {
      expect(await finalize(null), isNull);
    });

    test('keeps a primary-currency item without any rate lookup', () async {
      final repository = _FakeRateRepository();

      final result = await finalize(
        item(amount: 90000, categoryId: 'food'),
        repository: repository,
      );

      expect(result!.amount, 90000);
      expect(repository.calls, 0);
    });

    test('converts a foreign item into the primary currency', () async {
      final result = await finalize(
        item(categoryId: 'food', foreignCode: 'USD', foreignAmount: 5),
      );

      expect(result!.amount, 125000);
      expect(result.categoryId, 'food');
    });

    test('keeps the category but no amount when conversion fails', () async {
      final result = await finalize(
        item(categoryId: 'food', foreignCode: 'USD', foreignAmount: 5),
        repository: _FakeRateRepository(
          failure: const NetworkExchangeRateFailure(),
        ),
      );

      expect(result!.amount, isNull);
      expect(result.categoryId, 'food');
    });

    test('is null when nothing resolved after a failed conversion', () async {
      final result = await finalize(
        item(foreignCode: 'USD', foreignAmount: 5),
        repository: _FakeRateRepository(
          failure: const NetworkExchangeRateFailure(),
        ),
      );

      expect(result, isNull);
    });
  });

  group('liquidWallets', () {
    final investment = WalletEntity(
      id: 'inv',
      name: 'Gold',
      balance: 0,
      iconCode: 0,
      type: WalletType.investment,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    test('never offers an investment position to the model', () {
      final offered = useCase.liquidWallets([_wallet, investment]);

      expect(offered.map((w) => w.id), ['w1']);
    });
  });

  group('parseJsonResponse', () {
    for (final primary in codes) {
      test('keeps the amount when the stated currency is $primary itself', () {
        final parsed = parse(
          _json(amount: 1500, currencyCode: primary),
          primary,
        );

        expect(parsed!.foreignCurrencyCode, isNull);
        expect(parsed.result.amount, 1500);
      });

      test('keeps the amount when no currency is stated ($primary)', () {
        final parsed = parse(_json(amount: 1500), primary);

        expect(parsed!.foreignCurrencyCode, isNull);
        expect(parsed.result.amount, 1500);
      });

      test(
        'hands any other supported currency over for conversion ($primary)',
        () {
          for (final other in codes.where((c) => c != primary)) {
            final parsed = parse(
              _json(amount: 1500, currencyCode: other),
              primary,
            );

            expect(
              parsed!.foreignCurrencyCode,
              other,
              reason: '$other/$primary',
            );
            expect(parsed.foreignAmount, 1500, reason: '$other/$primary');
            expect(parsed.result.amount, isNull, reason: '$other/$primary');
          }
        },
      );
    }

    test('hands an unsupported currency over too', () {
      for (final unsupported in ['GBP', 'THB', 'SGD']) {
        final parsed = parse(
          _json(amount: 20, currencyCode: unsupported),
          'VND',
        );

        expect(parsed!.foreignCurrencyCode, unsupported);
        expect(parsed.foreignAmount, 20);
        expect(parsed.result.amount, isNull);
      }
    });

    test('keeps the foreign amount unrounded for conversion', () {
      final parsed = parse(_json(amount: 12.5, currencyCode: 'USD'), 'VND');

      expect(parsed!.foreignAmount, 12.5);
    });

    test('keeps a sub-unit foreign amount that rounds to zero', () {
      final parsed = parse(_json(amount: 0.4, currencyCode: 'USD'), 'VND');

      expect(parsed!.foreignAmount, 0.4);
    });

    test('has no foreign amount when it is zero or negative', () {
      for (final amount in [0, -5]) {
        final parsed = parse(_json(amount: amount, currencyCode: 'USD'), 'VND');

        expect(parsed!.foreignCurrencyCode, 'USD');
        expect(parsed.foreignAmount, isNull);
      }
    });

    test('normalises case and whitespace on the stated code', () {
      final same = parse(_json(amount: 12, currencyCode: ' usd '), 'USD');
      final other = parse(_json(amount: 12, currencyCode: ' usd '), 'VND');

      expect(same!.foreignCurrencyCode, isNull);
      expect(other!.foreignCurrencyCode, 'USD');
    });

    test('ignores placeholder values that are not an ISO code', () {
      for (final placeholder in ['', 'null', 'N/A', 'none', 'đ', 42]) {
        final parsed = parse(
          _json(amount: 50000, currencyCode: placeholder),
          'VND',
        );

        expect(parsed!.foreignCurrencyCode, isNull, reason: '$placeholder');
        expect(parsed.result.amount, 50000, reason: '$placeholder');
      }
    });

    test('keeps the other fields when the currency is foreign', () {
      final parsed = parse(
        _json(amount: 50, currencyCode: 'USD', categoryId: 'food'),
        'VND',
      );

      expect(parsed!.result.amount, isNull);
      expect(parsed.result.categoryId, 'food');
    });

    test('rounds decimals to whole units', () {
      expect(parse(_json(amount: 12.4), 'USD')!.result.amount, 12);
      expect(parse(_json(amount: 12.6), 'USD')!.result.amount, 13);
    });

    test('treats an amount that rounds to zero as missing', () {
      expect(parse(_json(amount: 0.4), 'USD')!.result.amount, isNull);
      expect(parse(_json(amount: 0), 'USD')!.result.amount, isNull);
      expect(parse(_json(amount: -5), 'USD')!.result.amount, isNull);
    });

    test('strips markdown fences around the JSON', () {
      final raw = '```json\n${_json(amount: 70000)}\n```';

      expect(parse(raw, 'VND')!.result.amount, 70000);
    });

    test('returns null for malformed JSON', () {
      expect(parse('not json', 'VND'), isNull);
    });
  });

  group('mergeCloudResponse', () {
    Future<QuickEntryParseResult?> merge(
      String raw, {
      required String primary,
      QuickEntryParseResult local = const QuickEntryParseResult(),
      _FakeRateRepository? repository,
    }) => _useCaseWith(repository ?? _FakeRateRepository()).mergeCloudResponse(
      raw,
      categories: [_food],
      wallets: [_wallet],
      localResult: local,
      currency: CurrencyCatalog.getDefinition(primary),
    );

    test('converts a foreign amount into the primary currency', () async {
      final merged = await merge(
        _json(amount: 5, currencyCode: 'USD', categoryId: 'food'),
        primary: 'VND',
      );

      expect(merged!.amount, 125000);
      expect(merged.categoryId, 'food');
    });

    test('converts through each supported primary currency', () async {
      final cases = {
        ('VND', 'USD', 10): 250000,
        ('USD', 'VND', 250000): 10,
        ('USD', 'EUR', 90): 100,
        ('JPY', 'USD', 10): 1500,
        ('USD', 'JPY', 1500): 10,
        ('KRW', 'CNY', 70): 13500,
      };

      for (final entry in cases.entries) {
        final (primary, foreign, amount) = entry.key;
        final merged = await merge(
          _json(amount: amount, currencyCode: foreign, categoryId: 'food'),
          primary: primary,
        );

        expect(
          merged!.amount,
          entry.value,
          reason: '$amount $foreign→$primary',
        );
      }
    });

    test('converts the exact decimal amount, not a rounded one', () async {
      final merged = await merge(
        _json(amount: 12.5, currencyCode: 'USD', categoryId: 'food'),
        primary: 'VND',
      );

      expect(merged!.amount, 312500);
    });

    test(
      'does not hit the rate repository for a primary-currency amount',
      () async {
        final repository = _FakeRateRepository();

        final merged = await merge(
          _json(amount: 70000, currencyCode: 'VND', categoryId: 'food'),
          primary: 'VND',
          repository: repository,
        );

        expect(merged!.amount, 70000);
        expect(repository.calls, 0);
      },
    );

    test(
      'never falls back to the local amount for a foreign currency',
      () async {
        final merged = await merge(
          _json(amount: 50, currencyCode: 'USD', categoryId: 'food'),
          primary: 'VND',
          local: const QuickEntryParseResult(amount: 50),
          repository: _FakeRateRepository(
            failure: const NetworkExchangeRateFailure(),
          ),
        );

        expect(merged!.amount, isNull);
        expect(merged.categoryId, 'food');
      },
    );

    test('leaves the amount empty when only fallback rates exist', () async {
      for (final provenance in [
        RateProvenance.staleCache,
        RateProvenance.offlineFallback,
      ]) {
        final merged = await merge(
          _json(amount: 5, currencyCode: 'USD', categoryId: 'food'),
          primary: 'VND',
          repository: _FakeRateRepository(provenance: provenance),
        );

        expect(merged!.amount, isNull, reason: '$provenance');
      }
    });

    test('accepts a freshly cached rate', () async {
      final merged = await merge(
        _json(amount: 5, currencyCode: 'USD', categoryId: 'food'),
        primary: 'VND',
        repository: _FakeRateRepository(provenance: RateProvenance.freshCache),
      );

      expect(merged!.amount, 125000);
    });

    test('leaves the amount empty for an unsupported currency', () async {
      final repository = _FakeRateRepository();

      final merged = await merge(
        _json(amount: 20, currencyCode: 'GBP', categoryId: 'food'),
        primary: 'VND',
        repository: repository,
      );

      expect(merged!.amount, isNull);
      expect(merged.categoryId, 'food');
      expect(repository.calls, 0);
    });

    test('leaves the amount empty when it converts to zero', () async {
      final merged = await merge(
        _json(amount: 1, currencyCode: 'VND', categoryId: 'food'),
        primary: 'USD',
      );

      expect(merged!.amount, isNull);
    });

    test('survives a rate lookup that throws', () async {
      final merged = await merge(
        _json(amount: 5, currencyCode: 'USD', categoryId: 'food'),
        primary: 'VND',
        repository: _FakeRateRepository(throws: true),
      );

      expect(merged!.amount, isNull);
      expect(merged.categoryId, 'food');
    });

    test('is null when a failed conversion leaves nothing to apply', () async {
      final merged = await merge(
        _json(amount: 50, currencyCode: 'EUR'),
        primary: 'USD',
        repository: _FakeRateRepository(
          failure: const NetworkExchangeRateFailure(),
        ),
      );

      expect(merged, isNull);
    });

    test('falls back to the local amount when the cloud has none', () async {
      final merged = await merge(
        _json(categoryId: 'food'),
        primary: 'USD',
        local: const QuickEntryParseResult(amount: 9),
      );

      expect(merged!.amount, 9);
    });

    test('uses the cloud amount in the primary currency', () async {
      final merged = await merge(
        _json(amount: 35, currencyCode: 'EUR', categoryId: 'food'),
        primary: 'EUR',
        local: const QuickEntryParseResult(amount: 1),
      );

      expect(merged!.amount, 35);
    });
  });
}
