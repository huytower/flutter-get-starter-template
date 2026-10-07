import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_types.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import 'exchange_rate_local_datasource.dart';
import 'frankfurter_remote.dart';
import 'rate_freshness.dart';

@LazySingleton(as: ExchangeRateRepository)
class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  ExchangeRateRepositoryImpl(this._remote, this._local, this._freshness);

  final FrankfurterRemote _remote;
  final ExchangeRateLocalDataSource _local;
  final RateFreshness _freshness;

  static const String _provider = 'frankfurter';

  /// Baseline pivot rates against USD for robust offline/unsupported base fallback.
  static const Map<String, double> _baselineRatesAgainstUsd = {
    'USD': 1.0,
    'VND': 25982.50,
    'EUR': 0.92,
    'JPY': 153.50,
    'KRW': 1350.00,
    'CNY': 7.20,
  };

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
        if (date != null || _freshness.isFresh(cached.fetchedAt)) {
          return Success(
            ExchangeRateResult(
              table: cached,
              provenance: RateProvenance.freshCache,
            ),
          );
        }
      }
    }

    // 2. Fetch from API
    try {
      final response = await _remote.getRates(
        validatedBase,
        date != null ? _formatDate(date) : null,
      );

      // 3. Validate response
      if (response.base.toUpperCase() != validatedBase.toUpperCase()) {
        return const Error(
          ValidationExchangeRateFailure('Response base currency mismatch'),
        );
      }

      final validatedRates = <String, double>{};
      for (final entry in response.rates.entries) {
        final qDef = CurrencyCatalog.tryGetDefinition(entry.key);
        if (qDef != null) {
          final rate = entry.value;
          if (rate > 0 && rate.isFinite) {
            validatedRates[qDef.code] = rate;
          }
        }
      }

      final hasAllFetchedQuotes = validatedQuotes.every(
        (q) => validatedRates.containsKey(q),
      );
      if (!hasAllFetchedQuotes) {
        return const Error(
          ValidationExchangeRateFailure(
            'Some requested quote currencies were missing in rate response',
          ),
        );
      }

      final effectiveDt =
          DateTime.tryParse(response.date) ?? (date ?? DateTime.now());
      final table = ExchangeRateTable(
        baseCurrency: validatedBase,
        rates: validatedRates,
        effectiveDate: effectiveDt,
        fetchedAt: DateTime.now(),
        provider: _provider,
      );

      // Cache result immediately and perform opportunistic cleanup
      await _local.cacheRates(table, validatedQuotes);
      try {
        await _local.deleteExpired(
          now: DateTime.now().toUtc(),
          retention: const Duration(days: 90),
        );
      } catch (e) {
        debugPrint('[ExchangeRateRepository] Cache cleanup failed: $e');
      }

      return Success(
        ExchangeRateResult(table: table, provenance: RateProvenance.network),
      );
    } catch (e) {
      debugPrint(
        '[ExchangeRateRepository] API fetch failed for base $validatedBase: $e (using fallback)',
      );
      if (cached != null && hasValidCachedQuotes) {
        return Success(
          ExchangeRateResult(
            table: cached,
            provenance: RateProvenance.staleCache,
          ),
        );
      }

      final baselineTable = _generateBaselineTable(
        validatedBase,
        validatedQuotes,
      );
      return Success(
        ExchangeRateResult(
          table: baselineTable,
          provenance: RateProvenance.offlineFallback,
        ),
      );
    }
  }

  ExchangeRateTable _generateBaselineTable(String base, List<String> quotes) {
    final baseUsdRate = _baselineRatesAgainstUsd[base.toUpperCase()] ?? 1.0;
    final rates = <String, double>{};
    for (final q in quotes) {
      final qUsdRate = _baselineRatesAgainstUsd[q.toUpperCase()] ?? 1.0;
      rates[q.toUpperCase()] = qUsdRate / baseUsdRate;
    }
    return ExchangeRateTable(
      baseCurrency: base.toUpperCase(),
      rates: rates,
      effectiveDate: DateTime.now().toUtc(),
      fetchedAt: DateTime.now().toUtc(),
      provider: 'baseline_pivot',
    );
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
}
