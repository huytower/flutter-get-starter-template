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

  static List<int> getIncomeSuggestions(int? birthYear) {
    if (birthYear == null) return quickAmounts;
    final age = DateTime.now().year - birthYear;
    if (age < 20) return incomeUnder20;
    if (age < 30) return income20To30;
    return incomeAbove30;
  }
}
