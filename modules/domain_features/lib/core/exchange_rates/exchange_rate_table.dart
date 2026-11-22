/// Dated exchange rates from [baseCurrency] to each quote currency.
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
