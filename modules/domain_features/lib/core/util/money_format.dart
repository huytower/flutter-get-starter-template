import 'package:intl/intl.dart';

/// Formats a VND amount into a short, human-readable form with a magnitude
/// suffix and two decimal places:
///   - `>= 1 tỷ` (1e9)  → `1.36tỷ`
///   - `>= 1 triệu` (1e6) → `1.36tr`
///   - `>= 1 nghìn` (1e3) → `500.00k`
///   - otherwise          → the whole number (e.g. `887`)
///
/// Negative amounts keep their sign (e.g. `-1.20tr`).
String formatVndShort(num value) {
  final amount = value.toDouble();
  final sign = amount < 0 ? '-' : '';
  final abs = amount.abs();

  if (abs >= 1e9) return '$sign${(abs / 1e9).toStringAsFixed(2)}tỷ';
  if (abs >= 1e6) return '$sign${(abs / 1e6).toStringAsFixed(2)}tr';
  if (abs >= 1e3) return '$sign${(abs / 1e3).toStringAsFixed(2)}k';
  return '$sign${abs.toStringAsFixed(0)}';
}

String formatVnd(num value) {
  final formatter = NumberFormat.decimalPattern('vi_VN');
  return formatter.format(value);
}

String formatVndWithSymbol(num value) => '${formatVnd(value)} đ';
