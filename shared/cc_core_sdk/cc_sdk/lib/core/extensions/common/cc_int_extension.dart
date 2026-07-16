/// Project-specific [int] extensions for number formatting.
extension CcIntExtension on int {
  /// Formats integer value to short notation with localized units.
  ///
  /// Examples:
  /// - 1500000000 → "1.5 billion"
  /// - 350000 → "350.000"
  /// - 2500000 → "2.5 million"
  /// - 3500 → "3.500"
  /// - 500 → "500"
  String formatShort({
    String billionUnit = 'billion',
    String millionUnit = 'million',
    String thousandUnit = 'thousand',
  }) {
    if (this >= 1000000000) {
      final val = this / 1000000000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)} $billionUnit';
    }
    if (this >= 1000000) {
      final val = this / 1000000;
      return '${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)} $millionUnit';
    }
    if (this >= 1000) {
      return toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
    }
    return '$this';
  }
}
