import 'package:intl/intl.dart';

/// Formats a VND amount into a short, human-readable form:
///   - Clean whole numbers: `1tỷ`, `1tr`, `50k`
///   - Decimal numbers: `1,36tỷ`, `1,2tr`
///
/// If [useFullSuffix] is true: `1 tỷ đồng`, `1,2 triệu đồng`, `50 nghìn đồng`.
///
/// Negative amounts keep their sign (e.g. `-1,2tr`).
String formatVndShort(num value, {bool useFullSuffix = false}) {
  final amount = value.toDouble();
  final sign = amount < 0 ? '-' : '';
  final abs = amount.abs();

  String format(double val, String unit) {
    if (val == val.toInt().toDouble()) {
      return '${val.toInt()}$unit';
    }
    // Remove trailing zeros and handle comma separator
    String s = val.toStringAsFixed(2);
    if (s.endsWith('.00')) s = s.substring(0, s.length - 3);
    if (s.contains('.') && s.endsWith('0')) s = s.substring(0, s.length - 1);
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
}

String formatVnd(num value) {
  final formatter = NumberFormat.decimalPattern('vi_VN');
  return formatter.format(value);
}

String formatVndWithSymbol(num value) => '${formatVnd(value)} đ';
