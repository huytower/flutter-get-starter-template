import 'exchange_rate_table.dart';
import 'rate_provenance.dart';

/// An exchange-rate table plus where it came from ([RateProvenance]).
class ExchangeRateResult {
  const ExchangeRateResult({required this.table, required this.provenance});

  final ExchangeRateTable table;
  final RateProvenance provenance;

  bool get hasUsable => hasUsableForDisplay;

  bool get hasUsableForDisplay =>
      provenance == RateProvenance.freshCache ||
      provenance == RateProvenance.staleCache ||
      provenance == RateProvenance.network ||
      provenance == RateProvenance.offlineFallback;

  bool get requiresFreshnessWarning =>
      provenance == RateProvenance.staleCache ||
      provenance == RateProvenance.offlineFallback;

  bool get hasSafeForPersistedConversion =>
      provenance == RateProvenance.freshCache ||
      provenance == RateProvenance.network;
}
