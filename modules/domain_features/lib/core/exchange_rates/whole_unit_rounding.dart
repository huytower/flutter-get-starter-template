/// Rounds converted money to whole units of its currency.
///
/// The book stores amounts as integers with no cents (§5 of the business
/// requirements), so every conversion between currencies is rounded. A
/// non-zero amount never rounds to 0: anything under 1 unit becomes 1 unit
/// (−1 for a negative amount), in every currency — e.g. 10,000 đ is about
/// USD 0.39 and is kept as 1 USD instead of disappearing from the book.
abstract final class WholeUnitRounding {
  static int round(num value) {
    final rounded = value.round();
    if (rounded != 0 || value == 0) return rounded;
    return value > 0 ? 1 : -1;
  }
}
