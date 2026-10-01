import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_types.dart';
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

  /// In-flight request map for request coalescing.
  final Map<String, Future<Result<ExchangeRateResult, ExchangeRateFailure>>>
  _inFlightRequests = {};

  @override
  Future<Result<ExchangeRateResult, ExchangeRateFailure>> getExchangeRates({
    required String baseCurrency,
    required List<String> quoteCurrencies,
    DateTime? date,
  }) async {
    final validatedBase = CurrencyConstants.validateCurrencyCode(baseCurrency);
    final validatedQuotes =
        quoteCurrencies
            .map((q) => CurrencyConstants.validateCurrencyCode(q))
            .toSet()
            .toList()
          ..sort();

    final dateStr = date != null
        ? _formatDate(date)
        : _formatDate(DateTime.now());

    final requestKey = '$validatedBase|$dateStr|${validatedQuotes.join(',')}';
    if (_inFlightRequests.containsKey(requestKey)) {
      return _inFlightRequests[requestKey]!;
    }

    final future = _getExchangeRatesInternal(
      validatedBase: validatedBase,
      validatedQuotes: validatedQuotes,
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

      // If cache is present and valid, check if it's fresh (or historical)
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

    // 2. Fetch from API (since cache was missing, invalid, or stale)
    try {
      final symbolsParam = validatedQuotes.isEmpty
          ? null
          : validatedQuotes.join(',');
      final response = await _remote.getRates(
        validatedBase,
        symbolsParam,
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
        final quoteCode = CurrencyConstants.validateCurrencyCode(entry.key);
        final rate = entry.value;
        if (rate > 0 && rate.isFinite) {
          validatedRates[quoteCode] = rate;
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

      // Cache result immediately (newest-cache-wins)
      await _local.cacheRates(table, validatedQuotes);

      return Success(
        ExchangeRateResult(table: table, provenance: RateProvenance.network),
      );
    } catch (e) {
      // Network request failed: if we have a valid cached version (even if stale), return staleCache
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

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
}
