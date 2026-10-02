import 'package:multiple_result/multiple_result.dart';

enum RateProvenance { freshCache, staleCache, network }

class ExchangeRateResult {
  const ExchangeRateResult({required this.table, required this.provenance});

  final ExchangeRateTable table;
  final RateProvenance provenance;

  bool get isUsableForDisplay =>
      provenance == RateProvenance.freshCache ||
      provenance == RateProvenance.staleCache ||
      provenance == RateProvenance.network;

  bool get requiresFreshnessWarning => provenance == RateProvenance.staleCache;

  bool get isSafeForPersistedConversion =>
      provenance == RateProvenance.freshCache ||
      provenance == RateProvenance.network;
}

enum ConversionUse { display, persist }

class ConvertedMoney {
  const ConvertedMoney({
    required this.amountMinorUnits,
    required this.currencyCode,
    required this.provenance,
  });

  final int amountMinorUnits;
  final String currencyCode;
  final RateProvenance provenance;

  bool get showStaleWarning => provenance == RateProvenance.staleCache;
}

/// Domain contract for exchange rate tables, repositories, and failures.
/// Independent of [CurrencyCatalog] (metadata vs dated rates).
class ExchangeRateTable {
  ExchangeRateTable({
    required this.baseCurrency,
    required Map<String, double> rates,
    required this.effectiveDate,
    required this.fetchedAt,
    required this.provider,
  }) : rates = Map.unmodifiable({
         for (final entry in rates.entries)
           entry.key.toUpperCase(): entry.value,
       }) {
    if (baseCurrency.trim().isEmpty) {
      throw ArgumentError('Base currency cannot be empty');
    }
    for (final entry in rates.entries) {
      if (entry.key.trim().isEmpty) {
        throw ArgumentError('Quote currency cannot be empty');
      }
      if (entry.value <= 0 || !entry.value.isFinite) {
        throw ArgumentError(
          'Rate for ${entry.key} must be positive and finite',
        );
      }
    }
  }

  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime effectiveDate;
  final DateTime fetchedAt;
  final String provider;
}

abstract class ExchangeRateRepository {
  Future<Result<ExchangeRateResult, ExchangeRateFailure>> getExchangeRates({
    required String baseCurrency,
    required List<String> quoteCurrencies,
    DateTime? date,
  });
}

sealed class ExchangeRateFailure {
  const ExchangeRateFailure();
}

class NetworkExchangeRateFailure extends ExchangeRateFailure {
  const NetworkExchangeRateFailure([this.message]);
  final String? message;
}

class CacheExchangeRateFailure extends ExchangeRateFailure {
  const CacheExchangeRateFailure([this.message]);
  final String? message;
}

class ValidationExchangeRateFailure extends ExchangeRateFailure {
  const ValidationExchangeRateFailure([this.message]);
  final String? message;
}

class UnsupportedCurrencyFailure extends ExchangeRateFailure {
  const UnsupportedCurrencyFailure(this.code);
  final String code;
}
