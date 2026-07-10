/// Quick-amount suggestion sets for the income form, keyed off the user's
/// age (birth year set in Profile). Values are tunable constants.
abstract class IncomeQuickAmounts {
  /// Under 30 years old.
  static const List<int> under30 = [
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

  /// 30 and above.
  static const List<int> from30 = [
    500000,
    1000000,
    5000000,
    10000000,
    15000000,
  ];

  /// No birth year configured — generic amounts.
  static const List<int> fallback = [
    10000,
    20000,
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
  ];

  static List<int> forBirthYear(int? birthYear) {
    if (birthYear == null) return fallback;
    final age = DateTime.now().year - birthYear;
    return age < 30 ? under30 : from30;
  }
}
