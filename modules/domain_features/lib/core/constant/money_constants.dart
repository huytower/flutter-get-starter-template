import 'dart:math';

import '../../core/constant/currency_catalog.dart';
import '../../core/di/di.dart';
import '../../core/exchange_rates/currency_conversion_service.dart';

abstract class MoneyConstants {
  /// standard quick amounts for transaction entries (Expense/Income/Transfer)
  static const List<int> quickAmounts = [
    10000,
    20000,
    30000,
    50000,
    100000,
    200000,
    300000,
    500000,
    1000000,
    2000000,
  ];

  /// quick amounts for setting budget limits (larger range)
  static const List<int> budgetQuickAmounts = [
    100000,
    200000,
    500000,
    1000000,
    2000000,
    5000000,
    10000000,
  ];

  /// quick amounts for wallet opening balances (wide range)
  static const List<int> walletQuickAmounts = [
    100000,
    500000,
    1000000,
    2000000,
    5000000,
    10000000,
    20000000,
    50000000,
  ];

  /// quick amounts for reconciliation actual balance keypad suggestions
  static const List<int> reconciliationQuickAmounts = [
    100000,
    200000,
    500000,
    1000000,
    2000000,
    5000000,
  ];

  /// Dynamic income suggestions (Age-based)
  static const List<int> incomeUnder20 = [
    50000,
    100000,
    200000,
    300000,
    500000,
    1000000,
    1500000,
    2000000,
    3000000,
  ];

  static const List<int> income20To30 = [
    200000,
    500000,
    1000000,
    2000000,
    3000000,
    5000000,
    7000000,
    10000000,
    12000000,
    15000000,
    20000000,
  ];

  static const List<int> incomeAbove30 = [
    200000,
    500000,
    1000000,
    3000000,
    5000000,
    10000000,
    15000000,
    20000000,
    25000000,
    30000000,
    40000000,
    50000000,
  ];

  /// Dynamic expense suggestions (Age-based)
  static const List<int> expenseUnder20 = [
    10000,
    20000,
    30000,
    50000,
    100000,
    150000,
    200000,
    300000,
    500000,
  ];

  static const List<int> expense20To30 = [
    20000,
    50000,
    100000,
    150000,
    200000,
    300000,
    500000,
    700000,
    1000000,
    1500000,
  ];

  static const List<int> expenseAbove30 = [
    50000,
    100000,
    200000,
    300000,
    500000,
    700000,
    1000000,
    1500000,
    2000000,
    3000000,
  ];

  /// Dynamic investment suggestions (Age-based)
  static const List<int> investmentUnder20 = [
    50000,
    100000,
    200000,
    300000,
    500000,
    1000000,
    2000000,
    3000000,
  ];

  static const List<int> investment20To30 = [
    200000,
    500000,
    1000000,
    2000000,
    5000000,
    10000000,
    20000000,
    50000000,
    100000000,
  ];

  static const List<int> investmentAbove30 = [
    1000000,
    5000000,
    10000000,
    20000000,
    50000000,
    100000000,
    200000000,
    500000000,
    1000000000,
  ];

  /// Dynamic liability suggestions (Age-based)
  static const List<int> liabilityUnder20 = [
    100000,
    200000,
    300000,
    500000,
    1000000,
    2000000,
    3000000,
  ];

  static const List<int> liability20To30 = [
    500000,
    1000000,
    2000000,
    3000000,
    5000000,
    10000000,
    20000000,
    50000000,
  ];

  static const List<int> liabilityAbove30 = [
    1000000,
    3000000,
    5000000,
    10000000,
    20000000,
    50000000,
    100000000,
    200000000,
  ];

  static List<int> getIncomeSuggestions(int? birthYear) {
    if (birthYear == null) return quickAmounts;
    final age = DateTime.now().year - birthYear;
    if (age < 20) return incomeUnder20;
    if (age < 30) return income20To30;
    return incomeAbove30;
  }

  static List<int> getExpenseSuggestions(int? birthYear) {
    if (birthYear == null) return quickAmounts;
    final age = DateTime.now().year - birthYear;
    if (age < 20) return expenseUnder20;
    if (age < 30) return expense20To30;
    return expenseAbove30;
  }

  static List<int> getInvestmentSuggestions(int? birthYear) {
    if (birthYear == null) return budgetQuickAmounts;
    final age = DateTime.now().year - birthYear;
    if (age < 20) return investmentUnder20;
    if (age < 30) return investment20To30;
    return investmentAbove30;
  }

  static List<int> getLiabilitySuggestions(int? birthYear) {
    if (birthYear == null) return budgetQuickAmounts;
    final age = DateTime.now().year - birthYear;
    if (age < 20) return liabilityUnder20;
    if (age < 30) return liability20To30;
    return liabilityAbove30;
  }

  static Future<List<int>> getConvertedQuickAmounts(
    List<int> baseVndAmounts,
    String targetCurrency,
  ) async {
    final normalized = targetCurrency.trim().toUpperCase();
    if (normalized == 'VND' || normalized.isEmpty) return baseVndAmounts;

    try {
      final conversionService = getIt<CurrencyConversionService>();
      final toDef = CurrencyCatalog.tryGetDefinition(normalized);
      final scale = toDef != null
          ? pow(10, toDef.decimalDigits).toDouble()
          : 1.0;

      final converted = <int>[];
      for (final amount in baseVndAmounts) {
        final result = await conversionService.convertAmount(
          amount: amount,
          fromCurrency: 'VND',
          toCurrency: normalized,
        );
        final minorUnits = result.tryGetSuccess() ?? amount;
        final majorUnits = (minorUnits / scale).round();
        converted.add(majorUnits);
      }
      return converted;
    } catch (_) {
      return baseVndAmounts;
    }
  }
}
