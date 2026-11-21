/// Keeps every stored amount in the user's primary currency, so entries are
/// added and subtracted exactly as shown (no conversion, no rounding).
///
/// ```dart
/// unawaited(getIt<BookCurrencyProvider>().keepAlignedWithPrimary());
/// ```
abstract interface class BookCurrencyProvider {
  /// Converts records not in the primary currency now, then again every time
  /// the primary currency changes. Call once, at shell start.
  Future<void> keepAlignedWithPrimary();
}
