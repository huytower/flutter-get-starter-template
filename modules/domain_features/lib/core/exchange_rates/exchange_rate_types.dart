/// Domain contract for exchange rate tables, repositories, and failures.
/// Independent of [CurrencyCatalog] (metadata vs dated rates).
class ExchangeRateTable {
  const ExchangeRateTable({
    required this.baseCurrency,
    required this.rates,
    required this.effectiveDate,
    required this.fetchedAt,
    required this.provider,
  });

  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime effectiveDate;
  final DateTime fetchedAt;
  final String provider;
}

abstract class ExchangeRateRepository {
  Future<ExchangeRateTable> getExchangeRates({
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
