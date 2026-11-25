class CurrencyDefinition {
  const CurrencyDefinition({
    required this.code,
    required this.nameKey,
    required this.symbol,
    required this.sampleAmount,
    required this.locale,
    required this.decimalDigits,
    required this.hasPrefixSymbol,
    this.aliases = const [],
  });

  final String code;
  final String nameKey;
  final String symbol;
  final int sampleAmount;
  final String locale;
  final int decimalDigits;
  final bool hasPrefixSymbol;
  final List<String> aliases;
}

