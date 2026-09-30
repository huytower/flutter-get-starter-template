/// Single Source of Truth (SSOT) for currency codes, default currency,
/// currency symbols, and locale/region mappings across the app.
class CurrencyConstants {
  CurrencyConstants._();

  static const String defaultCurrencyCode = 'VND';

  static const String vnd = 'VND';
  static const String usd = 'USD';
  static const String eur = 'EUR';
  static const String gbp = 'GBP';
  static const String jpy = 'JPY';

  static const List<String> supportedCurrencyCodes = [vnd, usd, eur, gbp, jpy];

  /// Gets the currency symbol for a given currency code.
  static String getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case usd:
        return '\$';
      case eur:
        return '€';
      case gbp:
        return '£';
      case jpy:
        return '¥';
      case vnd:
      default:
        return 'đ';
    }
  }

  /// Gets the number format locale for a given currency code.
  static String getLocale(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case vnd:
        return 'vi_VN';
      case usd:
      case eur:
      case gbp:
      case jpy:
      default:
        return 'en_US';
    }
  }
}
