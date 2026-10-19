import '../di/di.dart';
import '../exchange_rates/currency_conversion_service.dart';

abstract class MoneyConstants {
  /// standard quick amounts for transaction entries (Expense/Income/Transfer) - VND
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

  /// standard quick amounts - USD
  static const List<int> quickAmountsUsd = [1, 2, 4, 6, 8, 12, 20, 50, 100];

  /// standard quick amounts - EUR
  static const List<int> quickAmountsEur = [1, 2, 4, 6, 8, 12, 20, 50, 100];

  /// standard quick amounts - JPY
  static const List<int> quickAmountsJpy = [
    100,
    200,
    300,
    500,
    1000,
    2000,
    3000,
    5000,
    10000,
  ];

  /// standard quick amounts - KRW
  static const List<int> quickAmountsKrw = [
    1000,
    2000,
    3000,
    5000,
    10000,
    20000,
    30000,
    50000,
    100000,
  ];

  /// standard quick amounts - CNY
  static const List<int> quickAmountsCny = [
    5,
    10,
    20,
    30,
    50,
    100,
    200,
    500,
    1000,
  ];

  /// quick amounts for setting budget limits - VND
  static const List<int> budgetQuickAmounts = [
    100000,
    200000,
    500000,
    1000000,
    2000000,
    5000000,
    10000000,
  ];

  /// quick amounts for setting budget limits - USD
  static const List<int> budgetQuickAmountsUsd = [
    10,
    20,
    50,
    100,
    200,
    500,
    1000,
  ];

  /// quick amounts for setting budget limits - EUR
  static const List<int> budgetQuickAmountsEur = [
    10,
    20,
    50,
    100,
    200,
    500,
    1000,
  ];

  /// quick amounts for setting budget limits - JPY
  static const List<int> budgetQuickAmountsJpy = [
    1000,
    2000,
    5000,
    10000,
    20000,
    50000,
    100000,
  ];

  /// quick amounts for setting budget limits - KRW
  static const List<int> budgetQuickAmountsKrw = [
    10000,
    20000,
    50000,
    100000,
    200000,
    500000,
    1000000,
  ];

  /// quick amounts for setting budget limits - CNY
  static const List<int> budgetQuickAmountsCny = [
    50,
    100,
    200,
    500,
    1000,
    2000,
    5000,
  ];

  /// quick amounts for wallet opening balances - VND
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

  /// quick amounts for wallet opening balances - USD
  static const List<int> walletQuickAmountsUsd = [
    10,
    50,
    100,
    200,
    500,
    1000,
    2000,
    5000,
  ];

  /// quick amounts for wallet opening balances - EUR
  static const List<int> walletQuickAmountsEur = [
    10,
    50,
    100,
    200,
    500,
    1000,
    2000,
    5000,
  ];

  /// quick amounts for wallet opening balances - JPY
  static const List<int> walletQuickAmountsJpy = [
    1000,
    5000,
    10000,
    20000,
    50000,
    100000,
    200000,
    500000,
  ];

  /// quick amounts for wallet opening balances - KRW
  static const List<int> walletQuickAmountsKrw = [
    10000,
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
    5000000,
  ];

  /// quick amounts for wallet opening balances - CNY
  static const List<int> walletQuickAmountsCny = [
    100,
    500,
    1000,
    2000,
    5000,
    10000,
    20000,
    50000,
  ];

  /// quick amounts for reconciliation actual balance - VND
  static const List<int> reconciliationQuickAmounts = [
    100000,
    200000,
    500000,
    1000000,
    2000000,
    5000000,
  ];

  /// quick amounts for reconciliation actual balance - USD
  static const List<int> reconciliationQuickAmountsUsd = [
    10,
    20,
    50,
    100,
    200,
    500,
  ];

  /// quick amounts for reconciliation actual balance - EUR
  static const List<int> reconciliationQuickAmountsEur = [
    10,
    20,
    50,
    100,
    200,
    500,
  ];

  /// quick amounts for reconciliation actual balance - JPY
  static const List<int> reconciliationQuickAmountsJpy = [
    1000,
    2000,
    5000,
    10000,
    20000,
    50000,
  ];

  /// quick amounts for reconciliation actual balance - KRW
  static const List<int> reconciliationQuickAmountsKrw = [
    10000,
    20000,
    50000,
    100000,
    200000,
    500000,
  ];

  /// quick amounts for reconciliation actual balance - CNY
  static const List<int> reconciliationQuickAmountsCny = [
    50,
    100,
    200,
    500,
    1000,
    2000,
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

  static List<int> getQuickAmounts({String? currencyCode}) {
    final code = currencyCode?.toUpperCase();
    if (code == 'USD') return quickAmountsUsd;
    if (code == 'EUR') return quickAmountsEur;
    if (code == 'JPY') return quickAmountsJpy;
    if (code == 'KRW') return quickAmountsKrw;
    if (code == 'CNY') return quickAmountsCny;
    return quickAmounts;
  }

  static List<int> getBudgetQuickAmounts({String? currencyCode}) {
    final code = currencyCode?.toUpperCase();
    if (code == 'USD') return budgetQuickAmountsUsd;
    if (code == 'EUR') return budgetQuickAmountsEur;
    if (code == 'JPY') return budgetQuickAmountsJpy;
    if (code == 'KRW') return budgetQuickAmountsKrw;
    if (code == 'CNY') return budgetQuickAmountsCny;
    return budgetQuickAmounts;
  }

  static List<int> getWalletQuickAmounts({String? currencyCode}) {
    final code = currencyCode?.toUpperCase();
    if (code == 'USD') return walletQuickAmountsUsd;
    if (code == 'EUR') return walletQuickAmountsEur;
    if (code == 'JPY') return walletQuickAmountsJpy;
    if (code == 'KRW') return walletQuickAmountsKrw;
    if (code == 'CNY') return walletQuickAmountsCny;
    return walletQuickAmounts;
  }

  static List<int> getReconciliationQuickAmounts({String? currencyCode}) {
    final code = currencyCode?.toUpperCase();
    if (code == 'USD') return reconciliationQuickAmountsUsd;
    if (code == 'EUR') return reconciliationQuickAmountsEur;
    if (code == 'JPY') return reconciliationQuickAmountsJpy;
    if (code == 'KRW') return reconciliationQuickAmountsKrw;
    if (code == 'CNY') return reconciliationQuickAmountsCny;
    return reconciliationQuickAmounts;
  }

  static List<int> getIncomeSuggestions(
    int? birthYear, {
    String? currencyCode,
  }) {
    final code = currencyCode?.toUpperCase();
    if (code == 'USD') return quickAmountsUsd;
    if (code == 'EUR') return quickAmountsEur;
    if (code == 'JPY') return quickAmountsJpy;
    if (code == 'KRW') return quickAmountsKrw;
    if (code == 'CNY') return quickAmountsCny;
    if (birthYear == null) return quickAmounts;
    final age = DateTime.now().year - birthYear;
    if (age < 20) return incomeUnder20;
    if (age < 30) return income20To30;
    return incomeAbove30;
  }

  static List<int> getExpenseSuggestions(
    int? birthYear, {
    String? currencyCode,
  }) {
    final code = currencyCode?.toUpperCase();
    if (code == 'USD') return quickAmountsUsd;
    if (code == 'EUR') return quickAmountsEur;
    if (code == 'JPY') return quickAmountsJpy;
    if (code == 'KRW') return quickAmountsKrw;
    if (code == 'CNY') return quickAmountsCny;
    if (birthYear == null) return quickAmounts;
    final age = DateTime.now().year - birthYear;
    if (age < 20) return expenseUnder20;
    if (age < 30) return expense20To30;
    return expenseAbove30;
  }

  static List<int> getInvestmentSuggestions(
    int? birthYear, {
    String? currencyCode,
  }) {
    final code = currencyCode?.toUpperCase();
    if (code == 'USD') return budgetQuickAmountsUsd;
    if (code == 'EUR') return budgetQuickAmountsEur;
    if (code == 'JPY') return budgetQuickAmountsJpy;
    if (code == 'KRW') return budgetQuickAmountsKrw;
    if (code == 'CNY') return budgetQuickAmountsCny;
    if (birthYear == null) return budgetQuickAmounts;
    final age = DateTime.now().year - birthYear;
    if (age < 20) return investmentUnder20;
    if (age < 30) return investment20To30;
    return investmentAbove30;
  }

  static List<int> getLiabilitySuggestions(
    int? birthYear, {
    String? currencyCode,
  }) {
    final code = currencyCode?.toUpperCase();
    if (code == 'USD') return budgetQuickAmountsUsd;
    if (code == 'EUR') return budgetQuickAmountsEur;
    if (code == 'JPY') return budgetQuickAmountsJpy;
    if (code == 'KRW') return budgetQuickAmountsKrw;
    if (code == 'CNY') return budgetQuickAmountsCny;
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
    if (normalized == 'USD') return quickAmountsUsd;
    if (normalized == 'EUR') return quickAmountsEur;
    if (normalized == 'JPY') return quickAmountsJpy;
    if (normalized == 'KRW') return quickAmountsKrw;
    if (normalized == 'CNY') return quickAmountsCny;
    if (normalized == 'VND' || normalized.isEmpty) return baseVndAmounts;

    try {
      final conversionService = getIt<CurrencyConversionService>();
      final converted = <int>[];
      for (final amount in baseVndAmounts) {
        final result = await conversionService.convertAmount(
          amount: amount,
          fromCurrency: 'VND',
          toCurrency: normalized,
        );
        final convertedVal = result.tryGetSuccess() ?? amount;
        converted.add(convertedVal > 0 ? convertedVal : 1);
      }
      return converted;
    } catch (_) {
      return baseVndAmounts;
    }
  }
}
