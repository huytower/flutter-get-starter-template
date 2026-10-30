import 'dart:ui';

import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:geocoding/geocoding.dart';

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
      nameKey: 'profile.currency_vnd',
      symbol: 'đ',
      sampleAmount: 2500000,
      locale: 'vi_VN',
      decimalDigits: 0,
      isPrefixSymbol: false,
      aliases: ['vnd', 'dong', 'd', 'đ'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.usd,
      nameKey: 'profile.currency_usd',
      symbol: '\$',
      sampleAmount: 100,
      locale: 'en_US',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['usd', 'dollar', 'dollars', '\$'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.eur,
      nameKey: 'profile.currency_eur',
      symbol: '€',
      sampleAmount: 85,
      locale: 'en_US',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['eur', 'euro', 'euros', '€'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.jpy,
      nameKey: 'profile.currency_jpy',
      symbol: '¥',
      sampleAmount: 11347,
      locale: 'ja_JP',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['jpy', 'yen', '¥'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.krw,
      nameKey: 'profile.currency_krw',
      symbol: '₩',
      sampleAmount: 135000,
      locale: 'ko_KR',
      decimalDigits: 0,
      isPrefixSymbol: true,
      aliases: ['krw', 'won', '₩'],
    ),
    CurrencyDefinition(
      code: CurrencyConstants.cny,
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
        '[CurrencyCatalog] Currency detected from locale: country=$countryCode -> currency=$currency'
            .Log('CurrencyCatalog');
        return (currencyCode: currency, countryCode: countryCode);
      }

      // Language fallback
      final languageCode = locale.languageCode.toLowerCase();
      if (languageCode == 'vi') {
        '[CurrencyCatalog] Currency detected from language: vi -> VND'.Log(
          'CurrencyCatalog',
        );
        return (currencyCode: CurrencyConstants.vnd, countryCode: 'VN');
      }
      if (languageCode == 'ja') {
        '[CurrencyCatalog] Currency detected from language: ja -> JPY'.Log(
          'CurrencyCatalog',
        );
        return (currencyCode: CurrencyConstants.jpy, countryCode: 'JP');
      }
      if (languageCode == 'ko') {
        '[CurrencyCatalog] Currency detected from language: ko -> KRW'.Log(
          'CurrencyCatalog',
        );
        return (currencyCode: CurrencyConstants.krw, countryCode: 'KR');
      }
      if (languageCode == 'zh') {
        '[CurrencyCatalog] Currency detected from language: zh -> CNY'.Log(
          'CurrencyCatalog',
        );
        return (currencyCode: CurrencyConstants.cny, countryCode: 'CN');
      }
      if (languageCode == 'en') {
        '[CurrencyCatalog] Currency detected from language: en -> USD'.Log(
          'CurrencyCatalog',
        );
        return (currencyCode: CurrencyConstants.usd, countryCode: 'US');
      }
    } catch (e) {
      '[CurrencyCatalog] Error detecting currency from locale: $e'.Log(
        'CurrencyCatalog',
      );
    }

    '[CurrencyCatalog] Defaulting currency to USD (US)'.Log('CurrencyCatalog');
    return (currencyCode: CurrencyConstants.usd, countryCode: 'US');
  }

  /// Detects the suggested currency code based on device regional settings.
  static String detectSuggestedCurrency() {
    return detectSuggestedCurrencyWithDetails().currencyCode;
  }

  /// Asynchronously detects suggested currency code based on GPS location first,
  /// falling back to device regional locale settings if GPS is unavailable.
  static Future<({String currencyCode, String? countryCode})>
  detectSuggestedCurrencyFromGpsWithDetails() async {
    '[CurrencyCatalog] Starting GPS-based currency detection...'.Log(
      'CurrencyCatalog',
    );
    try {
      final lastKnownPosition = await CcLocationHelper.getLastKnownPosition();
      final position =
          lastKnownPosition ?? await CcLocationHelper.getCurrentPosition();

      if (position != null) {
        final placemarks = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final isoCountryCode = placemarks.first.isoCountryCode?.toUpperCase();
          if (isoCountryCode != null &&
              countryCodeToCurrency.containsKey(isoCountryCode)) {
            final currency = countryCodeToCurrency[isoCountryCode]!;
            '[CurrencyCatalog] GPS detection successful: country=$isoCountryCode -> currency=$currency'
                .Log('CurrencyCatalog');
            return (currencyCode: currency, countryCode: isoCountryCode);
          }
        }
      }
    } catch (e) {
      '[CurrencyCatalog] GPS detection failed, falling back to locale: $e'.Log(
        'CurrencyCatalog',
      );
    }

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
