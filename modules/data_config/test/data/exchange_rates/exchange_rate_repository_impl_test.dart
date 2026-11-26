import 'package:data_config/data/exchange_rates/exchange_rate_local_datasource.dart';
import 'package:data_config/data/exchange_rates/exchange_rate_repository_impl.dart';
import 'package:data_config/data/exchange_rates/frankfurter_remote.dart';
import 'package:data_config/data/exchange_rates/rate_freshness.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_failure.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_result.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_table.dart';
import 'package:domain_features/core/exchange_rates/rate_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemote implements FrankfurterRemote {
  _FakeRemote({this.rows = const [], this.fail = false});

  final List<FrankfurterRate> rows;
  final bool fail;
  int calls = 0;
  String? lastQuotes;

  @override
  Future<List<FrankfurterRate>> getRates(
    String base,
    String quotes,
    String? date,
  ) async {
    calls++;
    lastQuotes = quotes;
    if (fail) throw StateError('offline');
    return rows;
  }
}

class _FakeCache implements ExchangeRateLocalDataSource {
  ExchangeRateTable? stored;

  @override
  Future<ExchangeRateTable?> getCachedRates({
    required String provider,
    required String baseCurrency,
    required String effectiveDateStr,
    required List<String> quotes,
  }) async => stored;

  @override
  Future<void> cacheRates(ExchangeRateTable table, List<String> quotes) async =>
      stored = table;

  @override
  Future<int> deleteExpired({
    required DateTime now,
    required Duration retention,
  }) async => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ExchangeRateTable _table(
  Map<String, double> rates, {
  required DateTime fetchedAt,
}) => ExchangeRateTable(
  baseCurrency: 'USD',
  rates: rates,
  effectiveDate: fetchedAt,
  fetchedAt: fetchedAt,
  provider: 'frankfurter',
);

FrankfurterRate _row(String quote, double rate, {String base = 'USD'}) =>
    FrankfurterRate(base: base, quote: quote, rate: rate, date: '2026-11-26');

void main() {
  late _FakeCache cache;
  setUp(() => cache = _FakeCache());

  ExchangeRateRepositoryImpl repo(_FakeRemote remote) =>
      ExchangeRateRepositoryImpl(remote, cache, const RateFreshness());

  Future<ExchangeRateResult> rates(
    ExchangeRateRepositoryImpl repository,
    List<String> quotes,
  ) async => (await repository.getExchangeRates(
    baseCurrency: 'usd',
    quoteCurrencies: quotes,
  )).tryGetSuccess()!;

  test('parses the v2 row format (one object per quote)', () {
    final row = FrankfurterRate.fromJson({
      'date': '2026-11-26',
      'base': 'vnd',
      'quote': 'usd',
      'rate': 0.0000387,
    });

    expect(row.base, 'VND');
    expect(row.quote, 'USD');
    expect(row.rate, 0.0000387);
  });

  test('rejects an unsupported currency before any lookup', () async {
    final remote = _FakeRemote();
    final result = await repo(
      remote,
    ).getExchangeRates(baseCurrency: 'XXX', quoteCurrencies: const ['EUR']);

    expect(result.tryGetError(), isA<UnsupportedCurrencyFailure>());
    expect(remote.calls, 0);
  });

  test('serves a fresh cache without calling the network', () async {
    cache.stored = _table({'EUR': 0.9}, fetchedAt: DateTime.now());
    final remote = _FakeRemote();

    final result = await rates(repo(remote), const ['EUR']);

    expect(result.provenance, RateProvenance.freshCache);
    expect(remote.calls, 0);
  });

  test(
    'fetches every quote, VND included, from the provider and caches',
    () async {
      final remote = _FakeRemote(rows: [_row('EUR', 0.9), _row('VND', 26194)]);

      final result = await rates(repo(remote), const ['EUR', 'VND']);

      expect(result.provenance, RateProvenance.network);
      expect(result.table.rates, {'EUR': 0.9, 'VND': 26194});
      expect(remote.lastQuotes, 'EUR,VND');
      expect(cache.stored, same(result.table));
    },
  );

  test('the base itself is 1 and is not requested', () async {
    final remote = _FakeRemote(rows: [_row('EUR', 0.9)]);

    final result = await rates(repo(remote), const ['EUR', 'USD']);

    expect(result.table.rates['USD'], 1.0);
    expect(remote.lastQuotes, 'EUR');
  });

  test(
    'a quote the provider leaves out fails instead of being invented',
    () async {
      final remote = _FakeRemote(rows: [_row('EUR', 0.9)]);

      final result = await repo(remote).getExchangeRates(
        baseCurrency: 'USD',
        quoteCurrencies: const ['EUR', 'VND'],
      );

      expect(result.tryGetError(), isA<NetworkExchangeRateFailure>());
      expect(cache.stored, isNull);
    },
  );

  test('offline: serves the stale cache', () async {
    cache.stored = _table({
      'EUR': 0.8,
    }, fetchedAt: DateTime.now().subtract(const Duration(days: 3)));

    final result = await rates(repo(_FakeRemote(fail: true)), const ['EUR']);

    expect(result.provenance, RateProvenance.staleCache);
    expect(result.table.rates['EUR'], 0.8);
  });

  test('offline with no cache: fails, no made-up rates', () async {
    final result = await repo(
      _FakeRemote(fail: true),
    ).getExchangeRates(baseCurrency: 'USD', quoteCurrencies: const ['EUR']);

    expect(result.tryGetError(), isA<NetworkExchangeRateFailure>());
  });
}
