/// The top-level tabs of the main navigation shell, in display order.
///
/// The shell maps its bar index to a tab with [MainTab.fromIndex]; the bridge
/// resolves each tab to its feature page and refresh logic, so the shell never
/// imports a feature directly.
enum MainTab {
  budget,
  entry,
  profile;

  /// The tab at bar position [index]; [entry] for an unknown index.
  ///
  /// ```dart
  /// MainTab.fromIndex(0); // MainTab.budget
  /// ```
  static MainTab fromIndex(int index) =>
      index >= 0 && index < values.length ? values[index] : entry;
}
