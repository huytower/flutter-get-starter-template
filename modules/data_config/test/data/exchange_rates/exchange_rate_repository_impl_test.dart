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
  _FakeRemote({this.response, this.fail = false});

  final FrankfurterResponse? response;
  final bool fail;
  int calls = 0;

  @override
  Future<List<FrankfurterResponse>> getRates(String base, String? date) async {
    calls++;
    if (fail) throw StateError('offline');
    return [?response];
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
    'fetches, fills missing quotes from the USD pivot, and caches',
    () async {
      final remote = _FakeRemote(
        response: const FrankfurterResponse(
          base: 'USD',
          date: '2026-11-20',
          rates: {'EUR': 0.9},
        ),
      );

      final result = await rates(repo(remote), const ['EUR', 'VND']);

      expect(result.provenance, RateProvenance.network);
      expect(result.table.rates['EUR'], 0.9);
      expect(result.table.rates['VND'], greaterThan(1000));
      expect(cache.stored, same(result.table));
    },
  );

  test('offline: a stale cache wins over the baseline', () async {
    cache.stored = _table({
      'EUR': 0.8,
    }, fetchedAt: DateTime.now().subtract(const Duration(days: 3)));

    final result = await rates(repo(_FakeRemote(fail: true)), const ['EUR']);

    expect(result.provenance, RateProvenance.staleCache);
    expect(result.table.rates['EUR'], 0.8);
  });

  test('offline with no cache: falls back to the baseline pivot', () async {
    final result = await rates(repo(_FakeRemote(fail: true)), const ['EUR']);

    expect(result.provenance, RateProvenance.offlineFallback);
    expect(result.table.rates['EUR'], closeTo(0.92, 1e-9));
  });
}
