import 'package:domain_features/core/exchange_rates/whole_unit_rounding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rounds to the nearest whole unit', () {
    expect(WholeUnitRounding.round(4.49), 4);
    expect(WholeUnitRounding.round(4.5), 5);
    expect(WholeUnitRounding.round(25982.5), 25983);
  });

  test('a non-zero amount under 1 unit becomes 1 unit, in any currency', () {
    // 10,000 đ ≈ USD 0.39; 1,000 đ ≈ USD 0.04: both kept as 1 USD.
    expect(WholeUnitRounding.round(0.39), 1);
    expect(WholeUnitRounding.round(0.04), 1);
    expect(WholeUnitRounding.round(0.0001), 1);
  });

  test('a negative amount under 1 unit becomes -1', () {
    expect(WholeUnitRounding.round(-0.3), -1);
  });

  test('zero stays zero', () {
    expect(WholeUnitRounding.round(0), 0);
    expect(WholeUnitRounding.round(0.0), 0);
  });
}
