/// An amount in minor units together with its ISO currency code.
class CurrencyAmount {
  const CurrencyAmount({required this.amount, required this.currencyCode});

  final int amount;
  final String currencyCode;
}
