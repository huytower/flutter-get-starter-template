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

  /// Dynamic income suggestions (Age-based)
  static const List<int> incomeUnder30 = [
    100000,
    150000,
    200000,
    500000,
    1000000,
    1500000,
    2000000,
    3000000,
    4000000,
    5000000,
  ];

  static const List<int> incomeAbove30 = [
    500000,
    1000000,
    5000000,
    10000000,
    15000000,
  ];

  static List<int> getIncomeSuggestions(int? birthYear) {
    if (birthYear == null) return quickAmounts;
    final age = DateTime.now().year - birthYear;
    return age < 30 ? incomeUnder30 : incomeAbove30;
  }
}
