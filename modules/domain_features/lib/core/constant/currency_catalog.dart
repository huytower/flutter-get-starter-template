import 'dart:ui';

import 'package:cc_sdk/export_cc_sdk.dart';

/// ISO 4217 codes of the currencies the app supports. The single source for
/// these codes; `CurrencyConstants` re-exposes them.
abstract final class CurrencyCodes {
  static const String vnd = 'VND';
  static const String usd = 'USD';
  static const String jpy = 'JPY';
  static const String eur = 'EUR';
  static const String krw = 'KRW';
  static const String cny = 'CNY';
}

class CurrencyDefinition {
  const CurrencyDefinition({
    required this.code,
    required this.nameKey,
    required this.symbol,
    required this.sampleAmount,
    required this.locale,
    required this.decimalDigits,
    required this.isPrefixSymbol,
    this.aliases = const [],
  });

  final String code;
  final String nameKey;
  final String symbol;
  final int sampleAmount;
  final String locale;
  final int decimalDigits;
  final bool isPrefixSymbol;
  final List<String> aliases;
}

/// Centralized catalog and privacy-first initial currency detection
/// using device region and app locale (without requesting GPS permissions).
/// Restricted to: VND, USD, JPY, EUR, KRW, CNY.
class CurrencyCatalog {
  CurrencyCatalog._();

  static const List<CurrencyDefinition> definitions = [
    CurrencyDefinition(
      code: CurrencyCodes.vnd,
      nameKey: 'profile.currency_vnd',
      symbol: 'đ',
      sampleAmount: 2500000,
      locale: 'vi_VN',
      decimalDigits: 0,
      isPrefixSymbol: false,
      aliases: ['vnd', 'dong', 'd', 'đ'],
    ),
    CurrencyDefinition(
      code: CurrencyCodes.usd,
      nameKey: 'profile.currency_usd',
      symbol: '\$',
      sampleAmount: 100,
      locale: 'en_US',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['usd', 'dollar', 'dollars', '\$'],
    ),
    CurrencyDefinition(
      code: CurrencyCodes.eur,
      nameKey: 'profile.currency_eur',
      symbol: '€',
      sampleAmount: 85,
      locale: 'en_US',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['eur', 'euro', 'euros', '€'],
    ),
    CurrencyDefinition(
      code: CurrencyCodes.jpy,
      nameKey: 'profile.currency_jpy',
      symbol: '¥',
      sampleAmount: 11347,
      locale: 'ja_JP',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['jpy', 'yen', '¥'],
    ),
    CurrencyDefinition(
      code: CurrencyCodes.krw,
      nameKey: 'profile.currency_krw',
      symbol: '₩',
      sampleAmount: 135000,
      locale: 'ko_KR',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['krw', 'won', '₩'],
    ),
    CurrencyDefinition(
      code: CurrencyCodes.cny,
      nameKey: 'profile.currency_cny',
      symbol: '¥',
      sampleAmount: 639,
      locale: 'zh_CN',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['cny', 'rmb', 'yuan', '¥'],
    ),
  ];

  static CurrencyDefinition getDefinition(String code) {
    for (final def in definitions) {
      if (def.code.toUpperCase() == code.toUpperCase()) {
        return def;
      }
    }
    return definitions.first;
  }

  /// Mapping from country code (ISO 3166-1 alpha-2) to currency code.
  static const Map<String, String> countryCodeToCurrency = {
    'VN': CurrencyCodes.vnd,
    'US': CurrencyCodes.usd,
    'JP': CurrencyCodes.jpy,
    'FR': CurrencyCodes.eur,
    'DE': CurrencyCodes.eur,
    'IT': CurrencyCodes.eur,
    'ES': CurrencyCodes.eur,
    'NL': CurrencyCodes.eur,
    'EU': CurrencyCodes.eur,
    'KR': CurrencyCodes.krw,
    'CN': CurrencyCodes.cny,
  };

  static const Map<String, String> countryCodeToLanguageCode = {
    'VN': 'vi',
    'US': 'en',
    'JP': 'ja',
    'KR': 'ko',
    'CN': 'zh',
  };

  static String? languageCodeForCountry(String? countryCode) {
    final normalized = countryCode?.trim().toUpperCase();
    if (normalized == null) return null;
    return countryCodeToLanguageCode[normalized];
  }

  /// Detects suggested currency code along with detected country code.
  static ({String currencyCode, String? countryCode})
  detectSuggestedCurrencyWithDetails() {
    try {
      final locale = PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode?.toUpperCase();
      if (countryCode != null &&
          countryCodeToCurrency.containsKey(countryCode)) {
        final currency = countryCodeToCurrency[countryCode]!;
        return (currencyCode: currency, countryCode: countryCode);
      }

      // Language fallback
      final languageCode = locale.languageCode.toLowerCase();
      if (languageCode == 'vi') {
        return (currencyCode: CurrencyCodes.vnd, countryCode: 'VN');
      }
      if (languageCode == 'ja') {
        return (currencyCode: CurrencyCodes.jpy, countryCode: 'JP');
      }
      if (languageCode == 'ko') {
        return (currencyCode: CurrencyCodes.krw, countryCode: 'KR');
      }
      if (languageCode == 'zh') {
        return (currencyCode: CurrencyCodes.cny, countryCode: 'CN');
      }
      if (languageCode == 'en') {
        return (currencyCode: CurrencyCodes.usd, countryCode: 'US');
      }
    } catch (_) {}

    return (currencyCode: CurrencyCodes.usd, countryCode: 'US');
  }

  /// Detects the suggested currency code based on device regional settings.
  static String detectSuggestedCurrency() {
    return detectSuggestedCurrencyWithDetails().currencyCode;
  }

  /// Asynchronously detects suggested currency code based on GPS location first,
  /// falling back to device regional locale settings if GPS is unavailable.
  static Future<({String currencyCode, String? countryCode})>
  detectSuggestedCurrencyFromGpsWithDetails() async {
    try {
      // Resolved inside the try: without DI (e.g. in tests) this falls back to
      // the device locale below.
      final location = getIt<CcLocationService>();
      final position =
          await location.getLastKnownPosition() ??
          await location.getCurrentPosition();

      if (position != null) {
        final isoCountryCode = await location.countryCodeAt(position);
        if (isoCountryCode != null &&
            countryCodeToCurrency.containsKey(isoCountryCode)) {
          final currency = countryCodeToCurrency[isoCountryCode]!;
          return (currencyCode: currency, countryCode: isoCountryCode);
        }
      }
    } catch (_) {}

    // Fallback to locale / region detection if GPS detection fails or is unavailable
    final fallback = detectSuggestedCurrencyWithDetails();
    return fallback;
  }

  /// Tries to get the definition for a given currency code strictly.
  static CurrencyDefinition? tryGetDefinition(String? code) {
    final normalized = code?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final definition in definitions) {
      if (definition.code == normalized) return definition;
    }
    return null;
  }

  /// Checks whether a given currency code is supported strictly.
  static bool isSupported(String? code) => tryGetDefinition(code) != null;
}
