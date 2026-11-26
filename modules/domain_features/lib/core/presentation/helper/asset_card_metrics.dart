/// Design sizes of an asset card in a horizontal asset row (investment,
/// borrow and lend asset selectors), used to lay the row out and to centre a
/// card with `CcScrollReveal.reveal`.
abstract final class AssetCardMetrics {
  /// Width of one card: wide enough for a name such as "VPB Master 5678" on
  /// two lines without an ellipsis.
  static const double width = 81.6;

  /// Space between two cards (the rows separate items with `CcSpaceMD`, 12).
  static const double gap = 12;
}
