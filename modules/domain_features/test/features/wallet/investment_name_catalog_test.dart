import 'package:domain_features/features/wallet/domain/entities/suggestion_region.dart';
import 'package:domain_features/features/wallet/presentation/helper/investment_name_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

SuggestionRegion _resolve({
  String? currency,
  bool chosen = false,
  String? country,
}) => SuggestionRegion.resolve(
  currencyCode: currency,
  hasChosenCurrency: chosen,
  countryCode: country,
);

void main() {
  group('SuggestionRegion.resolve', () {
    test('a chosen currency wins over the detected country', () {
      expect(
        _resolve(currency: 'KRW', chosen: true, country: 'VN'),
        SuggestionRegion.kr,
      );
      expect(
        _resolve(currency: 'USD', chosen: true, country: 'VN'),
        SuggestionRegion.global,
      );
    });

    test('without a choice, the detected country decides', () {
      expect(_resolve(currency: 'VND', country: 'JP'), SuggestionRegion.jp);
      expect(_resolve(currency: 'VND', country: 'cn'), SuggestionRegion.cn);
      expect(_resolve(currency: 'VND', country: 'FR'), SuggestionRegion.global);
    });

    test('with no country, the currency decides; else global', () {
      expect(_resolve(currency: 'VND'), SuggestionRegion.vn);
      expect(_resolve(), SuggestionRegion.global);
    });
  });

  group('InvestmentNameCatalog', () {
    const categories = [
      'inv1',
      'inv2',
      'inv3',
      'inv4',
      'inv5',
      'inv6',
      'inv7',
      'inv8',
    ];

    test('every region lists names for every category, without repeats and '
        'short enough for the name field', () {
      for (final region in SuggestionRegion.values) {
        for (final category in categories) {
          final names = InvestmentNameCatalog.names(region, category);
          final where = '${region.name} $category';
          expect(names, isNotEmpty, reason: where);
          expect(names.toSet().length, names.length, reason: where);
          for (final name in names) {
            expect(name.trim(), name, reason: where);
            expect(name.length, lessThanOrEqualTo(30), reason: name);
          }
        }
      }
    });

    test('keeps the given order per region', () {
      expect(InvestmentNameCatalog.names(SuggestionRegion.vn, 'inv1').take(3), [
        'HPG',
        'SHB',
        'SSI',
      ]);
      expect(
        InvestmentNameCatalog.names(SuggestionRegion.vn, 'inv5').first,
        'Nhẫn trơn 9999',
      );
      expect(
        InvestmentNameCatalog.names(SuggestionRegion.global, 'inv1').first,
        'AAPL',
      );
      expect(
        InvestmentNameCatalog.names(SuggestionRegion.kr, 'inv1').first,
        '삼성전자',
      );
    });

    test('a category without a list offers nothing', () {
      expect(InvestmentNameCatalog.names(SuggestionRegion.vn, 'inv9'), isEmpty);
      expect(InvestmentNameCatalog.names(SuggestionRegion.vn, null), isEmpty);
    });
  });
}
