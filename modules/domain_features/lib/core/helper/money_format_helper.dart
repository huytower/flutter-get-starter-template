import 'package:intl/intl.dart';

/// Consolidated money formatting helper supporting multiple currencies
/// (e.g., VND, USD, EUR, etc.) based on currencyCode.
class MoneyFormatter {
  const MoneyFormatter();

  /// Gets the currency symbol for a given currency code.
  static String getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'VND':
      default:
        return 'đ';
    }
  }

  /// Formats a numeric amount with proper grouping separator according to currencyCode.
  static String formatAmount(num value, {String currencyCode = 'VND'}) {
    final code = currencyCode.toUpperCase();
    final locale = code == 'VND' ? 'vi_VN' : 'en_US';
    final formatter = NumberFormat.decimalPattern(locale);
    return formatter.format(value);
  }

  /// Formats a numeric amount with the currency symbol.
  static String formatWithSymbol(num value, {String currencyCode = 'VND'}) {
    final code = currencyCode.toUpperCase();
    final formattedNum = formatAmount(value, currencyCode: code);
    final symbol = getSymbol(code);
    if (code == 'USD' || code == 'EUR' || code == 'GBP' || code == 'JPY') {
      return '$symbol$formattedNum';
    }
    return '$formattedNum $symbol';
  }

  /// Formats an amount string for input fields (e.g. "1000000" -> "1.000.000" or "1,000,000").
  static String formatInput(String amount, {String currencyCode = 'VND'}) {
    if (amount.isEmpty || amount == '0') return amount;
    final parsed =
        int.tryParse(amount) ?? double.tryParse(amount)?.toInt() ?? 0;
    return formatAmount(parsed, currencyCode: currencyCode);
  }

  /// Formats amount into a short, human-readable form (e.g. 1.5M, 50K or 1tr, 50k).
  static String formatShort(
    num value, {
    String currencyCode = 'VND',
    bool useFullSuffix = false,
  }) {
    final code = currencyCode.toUpperCase();
    final amount = value.toDouble();
    final sign = amount < 0 ? '-' : '';
    final abs = amount.abs();

    if (code == 'VND') {
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

// Backward-compatible top-level wrapper functions
String formatVndShort(
  num value, {
  bool useFullSuffix = false,
  String currencyCode = 'VND',
}) => MoneyFormatter.formatShort(
  value,
  currencyCode: currencyCode,
  useFullSuffix: useFullSuffix,
);

String formatVnd(num value, {String currencyCode = 'VND'}) =>
    MoneyFormatter.formatAmount(value, currencyCode: currencyCode);

String formatVndWithSymbol(num value, {String currencyCode = 'VND'}) =>
    MoneyFormatter.formatWithSymbol(value, currencyCode: currencyCode);
