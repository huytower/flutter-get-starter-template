import 'package:intl/intl.dart';

import '../constant/currency_constants.dart';

/// Consolidated money formatting helper supporting multiple currencies
/// (e.g., VND, USD, EUR, etc.) based on currencyCode.
class MoneyFormatter {
  const MoneyFormatter();

  /// Gets the currency symbol for a given currency code.
  static String getSymbol(String currencyCode) =>
      CurrencyConstants.getSymbol(currencyCode);

  /// Formats a numeric amount with proper grouping separator according to currencyCode.
  static String formatAmount(
    num value, {
    String currencyCode = CurrencyConstants.defaultCurrencyCode,
  }) {
    final code = currencyCode.toUpperCase();
    final locale = CurrencyConstants.getLocale(code);
    final formatter = NumberFormat.decimalPattern(locale);
    return formatter.format(value);
  }

  /// Formats a numeric amount with the currency symbol.
  static String formatWithSymbol(
    num value, {
    String currencyCode = CurrencyConstants.defaultCurrencyCode,
  }) {
    final code = currencyCode.toUpperCase();
    final formattedNum = formatAmount(value, currencyCode: code);
    final symbol = getSymbol(code);
    if (code == CurrencyConstants.usd ||
        code == CurrencyConstants.eur ||
        code == CurrencyConstants.gbp ||
        code == CurrencyConstants.jpy) {
      return '$symbol$formattedNum';
    }
    return '$formattedNum $symbol';
  }

  /// Formats an amount string for input fields (e.g. "1000000" -> "1.000.000" or "1,000,000").
  static String formatInput(
    String amount, {
    String currencyCode = CurrencyConstants.defaultCurrencyCode,
  }) {
    if (amount.isEmpty || amount == '0') return amount;
    final parsed =
        int.tryParse(amount) ?? double.tryParse(amount)?.toInt() ?? 0;
    return formatAmount(parsed, currencyCode: currencyCode);
  }

  /// Formats amount into a short, human-readable form (e.g. 1.5M, 50K or 1tr, 50k).
  static String formatShort(
    num value, {
    String currencyCode = CurrencyConstants.defaultCurrencyCode,
    bool useFullSuffix = false,
  }) {
    final code = currencyCode.toUpperCase();
    final amount = value.toDouble();
    final sign = amount < 0 ? '-' : '';
    final abs = amount.abs();

    if (code == CurrencyConstants.vnd) {
      String format(double val, String unit) {
        if (val == val.toInt().toDouble()) {
          return '${val.toInt()}$unit';
        }
        String s = val.toStringAsFixed(2);
        if (s.endsWith('.00')) s = s.substring(0, s.length - 3);
        if (s.contains('.') && s.endsWith('0'))
          s = s.substring(0, s.length - 1);
        return '${s.replaceFirst('.', ',')}$unit';
      }

      if (abs >= 1e9) {
        return '$sign${format(abs / 1e9, useFullSuffix ? ' tỷ đồng' : 'tỷ')}';
      }
      if (abs >= 1e6) {
        return '$sign${format(abs / 1e6, useFullSuffix ? ' triệu đồng' : 'tr')}';
      }
      if (abs >= 1e3) {
        return '$sign${format(abs / 1e3, useFullSuffix ? ' nghìn đồng' : 'k')}';
      }
      return '$sign${abs.toStringAsFixed(0)}${useFullSuffix ? ' đồng' : ''}';
    } else {
      // USD / general format
      String format(double val, String unit) {
        if (val == val.toInt().toDouble()) {
          return '${val.toInt()}$unit';
        }
        String s = val.toStringAsFixed(1);
        if (s.endsWith('.00')) s = s.substring(0, s.length - 3);
        return '$s$unit';
      }

      if (abs >= 1e9) {
        return '$sign${format(abs / 1e9, useFullSuffix ? ' billions' : 'B')}';
      }
      if (abs >= 1e6) {
        return '$sign${format(abs / 1e6, useFullSuffix ? ' millions' : 'M')}';
      }
      if (abs >= 1e3) {
        return '$sign${format(abs / 1e3, useFullSuffix ? ' thousands' : 'K')}';
      }
      return '$sign${abs.toStringAsFixed(0)}';
    }
  }
}

// Neutral top-level helper functions
String formatCurrency(
  num value, {
  String currencyCode = CurrencyConstants.defaultCurrencyCode,
}) => MoneyFormatter.formatAmount(value, currencyCode: currencyCode);

String formatShortCurrency(
  num value, {
  bool useFullSuffix = false,
  String currencyCode = CurrencyConstants.defaultCurrencyCode,
}) => MoneyFormatter.formatShort(
  value,
  currencyCode: currencyCode,
  useFullSuffix: useFullSuffix,
);

String formatCurrencyWithSymbol(
  num value, {
  String currencyCode = CurrencyConstants.defaultCurrencyCode,
}) => MoneyFormatter.formatWithSymbol(value, currencyCode: currencyCode);

// Backward-compatible compatibility wrappers
String formatVndShort(
  num value, {
  bool useFullSuffix = false,
  String currencyCode = CurrencyConstants.defaultCurrencyCode,
}) => MoneyFormatter.formatShort(
  value,
  currencyCode: currencyCode,
  useFullSuffix: useFullSuffix,
);

String formatVnd(
  num value, {
  String currencyCode = CurrencyConstants.defaultCurrencyCode,
}) => MoneyFormatter.formatAmount(value, currencyCode: currencyCode);

String formatVndWithSymbol(
  num value, {
  String currencyCode = CurrencyConstants.defaultCurrencyCode,
}) => MoneyFormatter.formatWithSymbol(value, currencyCode: currencyCode);
