import 'dart:ui';

import 'currency_constants.dart';

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
      code: CurrencyConstants.vnd,
      nameKey: 'currency.vnd',
      symbol: 'đ',
      sampleAmount: 2500000,
      locale: 'vi_VN',
      decimalDigits: 0,
      isPrefixSymbol: false,
      aliases: ['vnd', 'dong', 'd', 'đ'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.usd,
      nameKey: 'currency.usd',
      symbol: '\$',
      sampleAmount: 100,
      locale: 'en_US',
      decimalDigits: 2,
      isPrefixSymbol: true,
      aliases: ['usd', 'dollar', 'dollars', '\$'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.eur,
      nameKey: 'currency.eur',
      symbol: '€',
      sampleAmount: 85,
      locale: 'en_US',
      decimalDigits: 2,
      isPrefixSymbol: true,
      aliases: ['eur', 'euro', 'euros', '€'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.jpy,
      nameKey: 'currency.jpy',
      symbol: '¥',
      sampleAmount: 11347,
      locale: 'ja_JP',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['jpy', 'yen', '¥'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.krw,
      nameKey: 'currency.krw',
      symbol: '₩',
      sampleAmount: 135000,
      locale: 'ko_KR',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['krw', 'won', '₩'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.cny,
      nameKey: 'currency.cny',
      symbol: '¥',
      sampleAmount: 639,
      locale: 'zh_CN',
      decimalDigits: 2,
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
