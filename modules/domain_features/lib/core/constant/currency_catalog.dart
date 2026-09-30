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

  /// Detects the suggested currency code based on device regional settings
  /// (platform dispatcher locale country code) without requesting GPS permissions.
  ///
  /// Detection Priority:
  /// 1. Device country code (e.g. VN -> VND, US -> USD).
  /// 2. Language fallback (e.g. 'vi' -> VND as primary market default).
  /// 3. Default fallback (VND).
  static String detectSuggestedCurrency() {
    try {
      final locale = PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode?.toUpperCase();
      if (countryCode != null &&
          countryCodeToCurrency.containsKey(countryCode)) {
        return countryCodeToCurrency[countryCode]!;
      }

      // Language fallback
      final languageCode = locale.languageCode.toLowerCase();
      if (languageCode == 'vi') {
        return CurrencyConstants.vnd;
      }
      if (languageCode == 'ja') {
        return CurrencyConstants.jpy;
      }
      if (languageCode == 'ko') {
        return CurrencyConstants.krw;
      }
      if (languageCode == 'zh') {
        return CurrencyConstants.cny;
      }
      if (languageCode == 'en') {
        return CurrencyConstants.usd;
      }
    } catch (_) {}

    return CurrencyConstants.defaultCurrencyCode;
  }
}
