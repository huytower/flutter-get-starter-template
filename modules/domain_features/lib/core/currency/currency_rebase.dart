import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';

/// Converts amounts into one target currency, all or nothing: callers convert
/// every value first and write only if none failed, so a missing rate never
/// leaves the book half converted.
class CurrencyRebase {
  CurrencyRebase(this._conversion, this.target);

  final CurrencyConversionService _conversion;

  /// The currency every amount is converted into.
  final String target;

  bool _failed = false;

  /// Whether any conversion so far had no rate.
  bool get failed => _failed;

  bool needs(String currencyCode) =>
      currencyCode.toUpperCase() != target.toUpperCase();

  /// [amount] in [from], expressed in [target] (unchanged if [from] already
  /// is the target). Records a failure and returns [amount] when no rate.
  Future<int> convert(int amount, String from) async {
    if (!needs(from)) return amount;
    final result = await _conversion.convertAmount(
      amount: amount,
      fromCurrency: from,
      toCurrency: target,
    );
    final converted = result.tryGetSuccess();
    if (converted == null) _failed = true;
    return converted ?? amount;
  }
}
