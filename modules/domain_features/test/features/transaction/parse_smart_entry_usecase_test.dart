import 'dart:convert';

import 'package:domain_features/core/ai/smart_entry_context.dart';
import 'package:domain_features/core/ai/smart_entry_response_parser.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_types.dart';
import 'package:domain_features/features/category/domain/entities/category_entity.dart';
import 'package:domain_features/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:domain_features/features/transaction/domain/entities/parsed_transaction_entity.dart';
import 'package:domain_features/features/transaction/domain/usecases/parse_smart_entry_usecase.dart';
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

final _wallet = WalletEntity(
  id: 'w1',
  name: 'Cash',
  balance: 0,
  iconCode: 0,
  type: WalletType.cash,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Map<String, Object?> _row({
  Object? amount,
  Object? currencyCode,
  String? categoryId,
  String? type,
}) => {
  'type': type,
  'amount': amount,
  'currencyCode': currencyCode,
  'categoryId': categoryId,
};

String _json(List<Map<String, Object?>> rows) =>
    jsonEncode({'transactions': rows});

ParseSmartEntryUseCase _useCaseWith(_FakeRateRepository repository) =>
    ParseSmartEntryUseCase(
      _FakeGetCategories(),
      CurrencyConversionService(repository),
    );

void main() {
  final useCase = _useCaseWith(_FakeRateRepository());

  SmartEntryContext context(String primary, {bool mixed = false}) =>
      SmartEntryContext(
        types: mixed
            ? const [CategoryType.expense, CategoryType.income]
            : const [CategoryType.expense],
        categories: const [
          (id: 'food', label: 'Food', type: CategoryType.expense),
          (id: 'salary', label: 'Salary', type: CategoryType.income),
        ],
        wallets: const [(id: 'w1', name: 'Cash')],
        currency: CurrencyCatalog.getDefinition(primary),
        language: 'English',
        today: DateTime(2026, 10, 26),
      );

  Future<List<ParsedTransactionEntity>> finalizeAll(
    String raw, {
    String primary = 'VND',
    bool mixed = false,
    ParsedTransactionEntity? local,
    _FakeRateRepository? repository,
  }) async {
    final parsed = SmartEntryResponseParser.parse(
      raw,
      context(primary, mixed: mixed),
      maxTransactions: 20,
    )!;
    return _useCaseWith(repository ?? _FakeRateRepository()).finalize(
      parsed,
      currency: CurrencyCatalog.getDefinition(primary),
      defaultType: CategoryType.expense,
      localResult: local,
    );
  }

  Future<ParsedTransactionEntity?> finalizeOne(
    String raw, {
    required String primary,
    ParsedTransactionEntity? local,
    _FakeRateRepository? repository,
  }) async => (await finalizeAll(
    raw,
    primary: primary,
    local: local,
    repository: repository,
  )).firstOrNull;

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

  group('finalize', () {
    test('converts a foreign amount into the primary currency', () async {
      final merged = await finalizeOne(
        _json([_row(amount: 5, currencyCode: 'USD', categoryId: 'food')]),
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
        final merged = await finalizeOne(
          _json([
            _row(amount: amount, currencyCode: foreign, categoryId: 'food'),
          ]),
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
      final merged = await finalizeOne(
        _json([_row(amount: 12.5, currencyCode: 'USD', categoryId: 'food')]),
        primary: 'VND',
      );

      expect(merged!.amount, 312500);
    });

    test('does not hit the rate repository for a primary amount', () async {
      final repository = _FakeRateRepository();

      final merged = await finalizeOne(
        _json([_row(amount: 70000, currencyCode: 'VND', categoryId: 'food')]),
        primary: 'VND',
        repository: repository,
      );

      expect(merged!.amount, 70000);
      expect(repository.calls, 0);
    });

    test(
      'never falls back to the local amount for a foreign currency',
      () async {
        final merged = await finalizeOne(
          _json([_row(amount: 50, currencyCode: 'USD', categoryId: 'food')]),
          primary: 'VND',
          local: const ParsedTransactionEntity(amount: 50),
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
        final merged = await finalizeOne(
          _json([_row(amount: 5, currencyCode: 'USD', categoryId: 'food')]),
          primary: 'VND',
          repository: _FakeRateRepository(provenance: provenance),
        );

        expect(merged!.amount, isNull, reason: '$provenance');
      }
    });

    test('accepts a freshly cached rate', () async {
      final merged = await finalizeOne(
        _json([_row(amount: 5, currencyCode: 'USD', categoryId: 'food')]),
        primary: 'VND',
        repository: _FakeRateRepository(provenance: RateProvenance.freshCache),
      );

      expect(merged!.amount, 125000);
    });

    test('leaves the amount empty for an unsupported currency', () async {
      final repository = _FakeRateRepository();

      final merged = await finalizeOne(
        _json([_row(amount: 20, currencyCode: 'GBP', categoryId: 'food')]),
        primary: 'VND',
        repository: repository,
      );

      expect(merged!.amount, isNull);
      expect(merged.categoryId, 'food');
      expect(repository.calls, 0);
    });

    test('leaves the amount empty when it converts to zero', () async {
      final merged = await finalizeOne(
        _json([_row(amount: 1, currencyCode: 'VND', categoryId: 'food')]),
        primary: 'USD',
      );

      expect(merged!.amount, isNull);
    });

    test('survives a rate lookup that throws', () async {
      final merged = await finalizeOne(
        _json([_row(amount: 5, currencyCode: 'USD', categoryId: 'food')]),
        primary: 'VND',
        repository: _FakeRateRepository(throws: true),
      );

      expect(merged!.amount, isNull);
      expect(merged.categoryId, 'food');
    });

    test('drops a row when a failed conversion leaves nothing', () async {
      final merged = await finalizeOne(
        _json([_row(amount: 50, currencyCode: 'EUR')]),
        primary: 'USD',
        repository: _FakeRateRepository(
          failure: const NetworkExchangeRateFailure(),
        ),
      );

      expect(merged, isNull);
    });

    test('uses the cloud amount in the primary currency', () async {
      final merged = await finalizeOne(
        _json([_row(amount: 35, currencyCode: 'EUR', categoryId: 'food')]),
        primary: 'EUR',
        local: const ParsedTransactionEntity(amount: 1),
      );

      expect(merged!.amount, 35);
    });
  });

  group('finalize with several rows', () {
    test('converts every row on its own currency, in order', () async {
      final rows = await finalizeAll(
        _json([
          _row(amount: 5, currencyCode: 'USD', categoryId: 'food'),
          _row(amount: 70000, categoryId: 'food'),
        ]),
      );

      expect(rows.map((e) => e.amount), [125000, 70000]);
    });

    test('drops only the row whose conversion left nothing', () async {
      final rows = await finalizeAll(
        _json([
          _row(amount: 5, currencyCode: 'USD'),
          _row(amount: 70000, categoryId: 'food'),
        ]),
        repository: _FakeRateRepository(
          failure: const NetworkExchangeRateFailure(),
        ),
      );

      expect(rows.map((e) => e.amount), [70000]);
    });

    test('never merges the local parse into a multi-row result', () async {
      final rows = await finalizeAll(
        _json([_row(categoryId: 'food'), _row(amount: 20, categoryId: 'food')]),
        local: const ParsedTransactionEntity(amount: 9),
      );

      expect(rows.map((e) => e.amount), [null, 20]);
    });

    test('keeps each row type in a mixed result', () async {
      final rows = await finalizeAll(
        _json([
          _row(amount: 10, type: 'expense', categoryId: 'food'),
          _row(amount: 99, type: 'income', categoryId: 'salary'),
        ]),
        mixed: true,
      );

      expect(rows.map((e) => e.type), ['expense', 'income']);
    });
  });

  group('finalize with a single row and a local parse', () {
    test('falls back to the local amount when the cloud has none', () async {
      final merged = await finalizeOne(
        _json([_row(categoryId: 'food')]),
        primary: 'USD',
        local: const ParsedTransactionEntity(amount: 9),
      );

      expect(merged!.amount, 9);
    });

    test('fills a missing category from the local parse', () async {
      final merged = await finalizeOne(
        _json([_row(amount: 5)]),
        primary: 'USD',
        local: const ParsedTransactionEntity(categoryId: 'food'),
      );

      expect(merged!.categoryId, 'food');
    });

    test(
      'keeps a local result alive when the cloud row came back empty',
      () async {
        final merged = await finalizeOne(
          _json([_row(amount: 50, currencyCode: 'EUR')]),
          primary: 'USD',
          local: const ParsedTransactionEntity(categoryId: 'food'),
          repository: _FakeRateRepository(
            failure: const NetworkExchangeRateFailure(),
          ),
        );

        expect(merged!.categoryId, 'food');
        expect(merged.amount, isNull);
      },
    );

    test('ignores a local category for a row of the other type', () async {
      final rows = await finalizeAll(
        _json([_row(amount: 100, type: 'income')]),
        mixed: true,
        local: const ParsedTransactionEntity(amount: 100, categoryId: 'food'),
      );

      expect(rows.single.type, 'income');
      expect(rows.single.categoryId, isNull);
    });
  });
}
