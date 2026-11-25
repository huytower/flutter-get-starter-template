import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:app_config/data/datasources/local/box/prj_hive_box.dart';
import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hive_ce/hive_ce.dart';

export 'currency_selection_source_type.dart';
export 'currency_selection_sources.dart';

/// Single Source of Truth (SSOT) for currency codes, default currency,
/// currency symbols, and locale/region mappings across the app.
/// Delegates metadata directly to [CurrencyCatalog] to prevent drift.
class CurrencyConstants {
  CurrencyConstants._();

  static const String defaultCurrencyCode = 'USD';

  static const String vnd = CurrencyCodes.vnd;
  static const String usd = CurrencyCodes.usd;
  static const String jpy = CurrencyCodes.jpy;
  static const String eur = CurrencyCodes.eur;
  static const String krw = CurrencyCodes.krw;
  static const String cny = CurrencyCodes.cny;

  /// Global reactive broadcast for when the primary currency changes.
  static final RxInt onCurrencyChanged = 0.obs;

  /// Global reactive broadcast for when GPS resolves a new country/region.
  static final RxInt onRegionalSettingsChanged = 0.obs;

  static List<String> get supportedCurrencyCodes =>
      CurrencyCatalog.definitions.map((d) => d.code).toList();

  /// Returns the active user primary currency (fallback to defaultCurrencyCode if uninitialized).
  static String get currentPrimaryCurrency {
    try {
      if (Hive.isBoxOpen(PrjHiveBox.APP_BOX_NAME)) {
        final code = PrjAppStorage.instance.currencyCode;
        if (code != null &&
            supportedCurrencyCodes.contains(code.toUpperCase())) {
          return code.toUpperCase();
        }
      }
    } catch (_) {}
    return defaultCurrencyCode;
  }

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
