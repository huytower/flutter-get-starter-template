import 'package:intl/intl.dart';

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

  /// Gets the number format locale for a given currency code and app language.
  static String getLocale(String currencyCode) {
    final code = currencyCode.toUpperCase();
    if (code == vnd) {
      return 'vi_VN';
    }
    try {
      final lang = Intl.getCurrentLocale().split('_').first.toLowerCase();
      if (lang == 'vi') {
        return 'vi_VN';
      }
    } catch (_) {}
    return 'en_US';
  }
}
