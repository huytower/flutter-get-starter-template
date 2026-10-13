import 'package:domain_features/core/constant/currency_catalog.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currency Detection & Country Mapping', () {
    test('countryCodeToCurrency correctly maps ISO country codes to currencies', () {
      expect(CurrencyCatalog.countryCodeToCurrency['VN'], CurrencyConstants.vnd);
      expect(CurrencyCatalog.countryCodeToCurrency['US'], CurrencyConstants.usd);
      expect(CurrencyCatalog.countryCodeToCurrency['JP'], CurrencyConstants.jpy);
      expect(CurrencyCatalog.countryCodeToCurrency['KR'], CurrencyConstants.krw);
      expect(CurrencyCatalog.countryCodeToCurrency['CN'], CurrencyConstants.cny);
      expect(CurrencyCatalog.countryCodeToCurrency['FR'], CurrencyConstants.eur);
      expect(CurrencyCatalog.countryCodeToCurrency['DE'], CurrencyConstants.eur);
    });

    test('detectSuggestedCurrencyWithDetails returns valid default currency on fallback', () {
      final suggestion = CurrencyCatalog.detectSuggestedCurrencyWithDetails();
      expect(CurrencyConstants.supportedCurrencyCodes.contains(suggestion.currencyCode), isTrue);
    });

    test('detectSuggestedCurrencyFromGpsWithDetails resolves asynchronously to valid currency', () async {
      final suggestion = await CurrencyCatalog.detectSuggestedCurrencyFromGpsWithDetails();
      expect(CurrencyConstants.supportedCurrencyCodes.contains(suggestion.currencyCode), isTrue);
    });
  });
}
