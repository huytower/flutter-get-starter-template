import 'currency_catalog.dart';

abstract final class CurrencySelectionSources {
  static const detected = 'detected';
  static const userSelected = 'user_selected';
  static const migrated = 'migrated';

  /// Validates and normalizes selection source strings; defaults to [migrated] if invalid.
  static String validate(String? source) {
    if (source != null) {
      final normalized = source.toLowerCase().trim();
      if (normalized == detected ||
          normalized == userSelected ||
          normalized == migrated) {
        return normalized;
      }
    }
    return migrated;
  }
}

enum CurrencySelectionSourceType {
  detected,
  userSelected,
  migrated;

  static CurrencySelectionSourceType parse(String? value) {
    return switch (CurrencySelectionSources.validate(value)) {
      CurrencySelectionSources.detected => CurrencySelectionSourceType.detected,
      CurrencySelectionSources.userSelected =>
        CurrencySelectionSourceType.userSelected,
      _ => CurrencySelectionSourceType.migrated,
    };
  }
}

/// Single Source of Truth (SSOT) for currency codes, default currency,
/// currency symbols, and locale/region mappings across the app.
/// Delegates metadata directly to [CurrencyCatalog] to prevent drift.
class CurrencyConstants {
  CurrencyConstants._();

  static const String defaultCurrencyCode = 'VND';

  static const String vnd = 'VND';
  static const String usd = 'USD';
  static const String jpy = 'JPY';
  static const String eur = 'EUR';
  static const String krw = 'KRW';
  static const String cny = 'CNY';

  static List<String> get supportedCurrencyCodes =>
      CurrencyCatalog.definitions.map((d) => d.code).toList();

  /// Validates whether [code] is a supported currency; returns [defaultCurrencyCode] otherwise.
  static String validateCurrencyCode(String? code) {
    if (code != null && supportedCurrencyCodes.contains(code.toUpperCase())) {
      return code.toUpperCase();
    }
    return defaultCurrencyCode;
  }

  /// Gets the currency symbol for a given currency code.
  static String getSymbol(String currencyCode) {
    return CurrencyCatalog.getDefinition(currencyCode).symbol;
  }

  /// Gets the number format locale for a given currency code.
  static String getLocale(String currencyCode) {
    return CurrencyCatalog.getDefinition(currencyCode).locale;
  }
}
