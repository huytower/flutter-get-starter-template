import 'rate_provenance.dart';

/// An amount converted into [currencyCode], with the provenance of the rate used.
class ConvertedMoney {
  const ConvertedMoney({
    required this.amount,
    required this.currencyCode,
    required this.provenance,
  });

  final int amount;
  final String currencyCode;
  final RateProvenance provenance;

  bool get showStaleWarning =>
      provenance == RateProvenance.staleCache ||
      provenance == RateProvenance.offlineFallback;
}
