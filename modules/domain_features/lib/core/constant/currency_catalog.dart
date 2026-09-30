import 'dart:ui';

import 'currency_constants.dart';

/// Centralized catalog and privacy-first initial currency detection
/// using device region and app locale (without requesting GPS permissions).
/// Restricted to: VND, USD, JPY, EUR, KRW, CNY.
class CurrencyCatalog {
  CurrencyCatalog._();

  /// Mapping from country code (ISO 3166-1 alpha-2) to currency code.
  static const Map<String, String> countryCodeToCurrency = {
    'VN': CurrencyConstants.vnd,
    'US': CurrencyConstants.usd,
    'JP': CurrencyConstants.jpy,
    'FR': CurrencyConstants.eur,
    'DE': CurrencyConstants.eur,
    'IT': CurrencyConstants.eur,
    'ES': CurrencyConstants.eur,
    'NL': CurrencyConstants.eur,
    'EU': CurrencyConstants.eur,
    'KR': CurrencyConstants.krw,
    'CN': CurrencyConstants.cny,
  };

  /// Detects suggested currency code along with detected country code.
  static ({String currencyCode, String? countryCode})
  detectSuggestedCurrencyWithDetails() {
    try {
      final locale = PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode?.toUpperCase();
      if (countryCode != null &&
          countryCodeToCurrency.containsKey(countryCode)) {
        return (
          currencyCode: countryCodeToCurrency[countryCode]!,
          countryCode: countryCode,
        );
      }

      // Language fallback
      final languageCode = locale.languageCode.toLowerCase();
      if (languageCode == 'vi') {
        return (currencyCode: CurrencyConstants.vnd, countryCode: 'VN');
      }
      if (languageCode == 'ja') {
        return (currencyCode: CurrencyConstants.jpy, countryCode: 'JP');
      }
      if (languageCode == 'ko') {
        return (currencyCode: CurrencyConstants.krw, countryCode: 'KR');
      }
      if (languageCode == 'zh') {
        return (currencyCode: CurrencyConstants.cny, countryCode: 'CN');
      }
      if (languageCode == 'en') {
        return (currencyCode: CurrencyConstants.usd, countryCode: 'US');
      }
    } catch (_) {}

    return (
      currencyCode: CurrencyConstants.defaultCurrencyCode,
      countryCode: null,
    );
  }

  /// Detects the suggested currency code based on device regional settings.
  static String detectSuggestedCurrency() {
    return detectSuggestedCurrencyWithDetails().currencyCode;
  }
}
