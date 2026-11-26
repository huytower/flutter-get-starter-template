import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_failure.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_repository.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_result.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_table.dart';
import 'package:domain_features/core/exchange_rates/rate_provenance.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import 'exchange_rate_local_datasource.dart';
import 'frankfurter_remote.dart';
import 'rate_freshness.dart';

/// Exchange rates from Frankfurter v2, cached locally.
///
/// Every rate comes from the provider. When the network fails, the last
/// cached rates are served (marked stale); with no cache the lookup fails.
/// No rate is ever hard-coded or estimated.
@LazySingleton(as: ExchangeRateRepository)
class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  ExchangeRateRepositoryImpl(this._remote, this._local, this._freshness);

  final FrankfurterRemote _remote;
  final ExchangeRateLocalDataSource _local;
  final RateFreshness _freshness;

  static const String _provider = 'frankfurter';

  /// In-flight request map for request coalescing.
  final Map<String, Future<Result<ExchangeRateResult, ExchangeRateFailure>>>
  _inFlightRequests = {};

  @override
  Future<Result<ExchangeRateResult, ExchangeRateFailure>> getExchangeRates({
    required String baseCurrency,
    required List<String> quoteCurrencies,
    DateTime? date,
  }) async {
    // 1. Strict validation before normalization
    final baseDef = CurrencyCatalog.tryGetDefinition(baseCurrency);
    if (baseDef == null) {
      return Error(UnsupportedCurrencyFailure(baseCurrency));
    }

    final quoteDefs = <CurrencyDefinition>[];
    for (final quote in quoteCurrencies) {
      final qDef = CurrencyCatalog.tryGetDefinition(quote);
      if (qDef == null) {
        return Error(UnsupportedCurrencyFailure(quote));
      }
      quoteDefs.add(qDef);
    }

    final normalizedBase = baseDef.code;
    final normalizedQuotes = quoteDefs.map((d) => d.code).toSet().toList()
      ..sort();

    final dateStr = date != null
        ? _formatDate(date)
        : _formatDate(DateTime.now());

    final requestKey = '$normalizedBase|$dateStr|${normalizedQuotes.join(',')}';
    if (_inFlightRequests.containsKey(requestKey)) {
      return _inFlightRequests[requestKey]!;
    }

    final future = _getExchangeRatesInternal(
      validatedBase: normalizedBase,
      validatedQuotes: normalizedQuotes,
      date: date,
      dateStr: dateStr,
    );

    _inFlightRequests[requestKey] = future;
    try {
      return await future;
    } finally {
      _inFlightRequests.remove(requestKey);
    }
  }

  Future<Result<ExchangeRateResult, ExchangeRateFailure>>
  _getExchangeRatesInternal({
    required String validatedBase,
    required List<String> validatedQuotes,
    required DateTime? date,
    required String dateStr,
  }) async {
    // 1. Check cache first with quote coverage verification
    final cached = await _local.getCachedRates(
      provider: _provider,
      baseCurrency: validatedBase,
      effectiveDateStr: dateStr,
      quotes: validatedQuotes,
    );

    bool hasValidCachedQuotes = false;
    if (cached != null) {
      hasValidCachedQuotes = validatedQuotes.every(
        (q) =>
            cached.rates.containsKey(q) &&
            cached.rates[q] != null &&
            cached.rates[q]! > 0 &&
            cached.rates[q]!.isFinite,
      );

      if (hasValidCachedQuotes) {
        if (date != null || _freshness.hasFresh(cached.fetchedAt)) {
          return Success(
            ExchangeRateResult(
              table: cached,
              provenance: RateProvenance.freshCache,
            ),
          );
        }
      }
    }

    // 2. Fetch from the API. A quote the provider does not return fails the
    // whole lookup: rates are never filled in from anywhere else.
    try {
      final table = await _fetchTable(validatedBase, validatedQuotes, date);

      // Cache result immediately and perform opportunistic cleanup
      await _local.cacheRates(table, validatedQuotes);
      try {
        await _local.deleteExpired(
          now: DateTime.now().toUtc(),
          retention: const Duration(days: 90),
        );
      } catch (e) {
        '[ExchangeRateRepository] Cache cleanup failed: $e'.Log(
          'ExchangeRateRepository',
        );
      }

      return Success(
        ExchangeRateResult(table: table, provenance: RateProvenance.network),
      );
    } catch (e) {
      '[ExchangeRateRepository] Rate fetch failed for base $validatedBase: $e'
          .Log('ExchangeRateRepository');

      // 3. Offline or provider error: the last rates the provider gave are
      // still real data, only older. Without them there is nothing to serve.
      if (cached != null && hasValidCachedQuotes) {
        return Success(
          ExchangeRateResult(
            table: cached,
            provenance: RateProvenance.staleCache,
          ),
        );
      }
      return Error(NetworkExchangeRateFailure(e.toString()));
    }
  }

  /// Builds a table from one `/v2/rates` call. Throws when the provider
  /// leaves out any requested quote.
  Future<ExchangeRateTable> _fetchTable(
    String base,
    List<String> quotes,
    DateTime? date,
  ) async {
    final rates = <String, double>{if (quotes.contains(base)) base: 1.0};
    final toFetch = quotes.where((q) => q != base).toList();
    var effectiveDate = '';

    if (toFetch.isNotEmpty) {
      final rows = await _remote.getRates(
        base,
        toFetch.join(','),
        date != null ? _formatDate(date) : null,
      );
      for (final row in rows) {
        final isRequested = row.base == base && toFetch.contains(row.quote);
        if (!isRequested || !(row.rate > 0) || !row.rate.isFinite) continue;
        rates[row.quote] = row.rate;
        if (row.date.compareTo(effectiveDate) > 0) effectiveDate = row.date;
      }
    }

    final missing = quotes.where((q) => !rates.containsKey(q)).toList();
    if (missing.isNotEmpty) {
      throw StateError('Provider returned no rate for ${missing.join(',')}');
    }

    return ExchangeRateTable(
      baseCurrency: base,
      rates: rates,
      effectiveDate:
          DateTime.tryParse(effectiveDate) ?? (date ?? DateTime.now()),
      fetchedAt: DateTime.now(),
      provider: _provider,
    );
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
}
