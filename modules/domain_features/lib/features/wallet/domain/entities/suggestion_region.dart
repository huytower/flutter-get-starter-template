/// The market whose names the app suggests (e.g. investment names). It follows
/// where the user's money is, not the UI language.
enum SuggestionRegion {
  vn,
  global,
  kr,
  jp,
  cn;

  /// The region the user is in, from what the app tracks:
  /// 1. the currency the user **chose** ([hasChosenCurrency]) — an explicit
  ///    confirmation;
  /// 2. otherwise the detected country (GPS or device locale);
  /// 3. otherwise the book currency.
  /// Anything without its own list (USD, EUR, other countries) is [global].
  static SuggestionRegion resolve({
    required String? currencyCode,
    required bool hasChosenCurrency,
    required String? countryCode,
  }) {
    final byCurrency = _byCurrency[currencyCode?.trim().toUpperCase()];
    if (hasChosenCurrency && byCurrency != null) return byCurrency;
    final country = countryCode?.trim().toUpperCase();
    if (country != null && country.isNotEmpty) {
      return _byCountry[country] ?? global;
    }
    return byCurrency ?? global;
  }

  static const Map<String, SuggestionRegion> _byCurrency = {
    'VND': vn,
    'KRW': kr,
    'JPY': jp,
    'CNY': cn,
    'USD': global,
    'EUR': global,
  };

  static const Map<String, SuggestionRegion> _byCountry = {
    'VN': vn,
    'KR': kr,
    'JP': jp,
    'CN': cn,
  };
}
