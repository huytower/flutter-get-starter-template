/// Design sizes of an asset card in a horizontal asset row (investment,
/// borrow and lend asset selectors), used to lay the row out and to centre a
/// card with `CcScrollReveal.reveal`.
abstract final class AssetCardMetrics {
  /// Width of one card.
  static const double width = 68;

  /// Space between two cards (the rows separate items with `CcSpaceMD`, 12).
  static const double gap = 12;
}
