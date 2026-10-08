import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:intl/intl.dart';

import '../constant/currency_constants.dart';

/// Consolidated money formatting helper supporting multiple currencies
/// (e.g., VND, USD, EUR, etc.) and locale-aware short representations.
class MoneyFormatter {
  const MoneyFormatter();

  /// Gets the currency symbol for a given currency code.
  static String getSymbol(String currencyCode) =>
      CurrencyConstants.getSymbol(currencyCode);

  static String _resolveCurrencyCode(String? currencyCode) {
    if (currencyCode != null && currencyCode.isNotEmpty) {
      return currencyCode;
    }
    try {
      final stored = CcAppStorage.instance.currencyCode;
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }
    } catch (_) {}
    return CurrencyConstants.defaultCurrencyCode;
  }

  /// Formats a numeric amount with proper grouping separator according to currencyCode.
  static String formatAmount(num value, {String? currencyCode}) {
    final code = _resolveCurrencyCode(currencyCode).toUpperCase();
    final locale = CurrencyConstants.getLocale(code);
    final formatter = NumberFormat.decimalPattern(locale);
    return formatter.format(value);
  }

  /// Formats a numeric amount with the currency symbol.
  static String formatWithSymbol(num value, {String? currencyCode}) {
    final code = _resolveCurrencyCode(currencyCode).toUpperCase();
    final formattedNum = formatAmount(value, currencyCode: code);
    final symbol = getSymbol(code);
    if (code == CurrencyConstants.usd ||
        code == CurrencyConstants.eur ||
        code == CurrencyConstants.krw ||
        code == CurrencyConstants.cny ||
        code == CurrencyConstants.jpy) {
      return '$symbol$formattedNum';
    }
    return '$formattedNum $symbol';
  }

  /// Formats an amount string for input fields (e.g. "1000000" -> "1.000.000" or "1,000,000").
  static String formatInput(String amount, {String? currencyCode}) {
    if (amount.isEmpty || amount == '0') return amount;
    final parsed =
        int.tryParse(amount) ?? double.tryParse(amount)?.toInt() ?? 0;
    return formatAmount(parsed, currencyCode: currencyCode);
  }

  /// Formats amount into a short, human-readable form (e.g. 1.5M, 50K for English; 1.5tr, 50k for Vietnamese).
  static String formatShort(
    num value, {
    String? currencyCode,
    bool useFullSuffix = false,
  }) {
    final code = _resolveCurrencyCode(currencyCode).toUpperCase();
    final amount = value.toDouble();
    final sign = amount < 0 ? '-' : '';
    final abs = amount.abs();

    // Detect language code (vi vs en)
    String lang = 'vi';
    try {
      final currentLocale = Intl.getCurrentLocale();
      if (currentLocale.isNotEmpty) {
        lang = currentLocale.split('_').first.toLowerCase();
      }
    } catch (_) {}

    final isVi = lang == 'vi';

    String format(double val, String unit, {bool useComma = true}) {
      if (val == val.toInt().toDouble()) {
        return '${val.toInt()}$unit';
      }
      String s = val.toStringAsFixed(2);
      if (s.endsWith('.00')) s = s.substring(0, s.length - 3);
      if (s.contains('.') && s.endsWith('0')) s = s.substring(0, s.length - 1);
      if (useComma) {
        return '${s.replaceFirst('.', ',')}$unit';
      }
      return '$s$unit';
    }

    if (code == CurrencyConstants.vnd) {
      if (abs >= 1e9) {
        return '$sign${format(abs / 1e9, isVi ? (useFullSuffix ? ' tỷ đồng' : 'tỷ') : (useFullSuffix ? ' billions' : 'B'), useComma: isVi)}';
      }
      if (abs >= 1e6) {
        return '$sign${format(abs / 1e6, isVi ? (useFullSuffix ? ' triệu đồng' : 'tr') : (useFullSuffix ? ' millions' : 'M'), useComma: isVi)}';
      }
      if (abs >= 1e3) {
        return '$sign${format(abs / 1e3, isVi ? (useFullSuffix ? ' nghìn đồng' : 'k') : (useFullSuffix ? ' thousands' : 'K'), useComma: isVi)}';
      }
      return '$sign${abs.toStringAsFixed(0)}${useFullSuffix ? (isVi ? ' đồng' : '') : ''}';
    } else {
      // Non-VND currencies (USD, EUR, GBP, JPY, etc.)
      if (abs >= 1e9) {
        return '$sign${format(abs / 1e9, useFullSuffix ? ' billions' : 'B', useComma: false)}';
      }
      if (abs >= 1e6) {
        return '$sign${format(abs / 1e6, useFullSuffix ? ' millions' : 'M', useComma: false)}';
      }
      if (abs >= 1e3) {
        return '$sign${format(abs / 1e3, useFullSuffix ? ' thousands' : 'K', useComma: false)}';
      }
      return '$sign${abs.toStringAsFixed(0)}';
    }
  }
}

// Neutral top-level helper functions
String formatCurrency(num value, {String? currencyCode}) =>
    MoneyFormatter.formatAmount(value, currencyCode: currencyCode);

String formatShortCurrency(
  num value, {
  bool useFullSuffix = false,
  String? currencyCode,
}) => MoneyFormatter.formatShort(
  value,
  currencyCode: currencyCode,
  useFullSuffix: useFullSuffix,
);

String formatCurrencyWithSymbol(num value, {String? currencyCode}) =>
    MoneyFormatter.formatWithSymbol(value, currencyCode: currencyCode);

// Backward-compatible compatibility wrappers
@Deprecated('Use formatShortCurrency instead')
String formatVndShort(
  num value, {
  bool useFullSuffix = false,
  String? currencyCode,
}) => MoneyFormatter.formatShort(
  value,
  currencyCode: currencyCode,
  useFullSuffix: useFullSuffix,
);

@Deprecated('Use formatCurrency instead')
String formatVnd(num value, {String? currencyCode}) =>
    MoneyFormatter.formatAmount(value, currencyCode: currencyCode);

@Deprecated('Use formatCurrencyWithSymbol instead')
String formatVndWithSymbol(num value, {String? currencyCode}) =>
    MoneyFormatter.formatWithSymbol(value, currencyCode: currencyCode);
