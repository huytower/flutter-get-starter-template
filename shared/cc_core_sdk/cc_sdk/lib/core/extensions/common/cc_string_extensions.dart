/// Project-specific [String] extensions.
///
/// Prefer [dartx](https://pub.dev/packages/dartx) for common helpers:
/// `capitalize()`, `decapitalize()`, `isNullOrEmpty`, `orEmpty()`, etc.
extension CcStringExtension on String {
  /// Broad "effectively empty" check — blank, `"null"`, `"{}"`, `"false"`, `"0"`.
  bool get isEffectivelyEmpty {
    final trimmed = replaceAll(' ', '');
    return ['', 'null', '{}', 'false', '0'].contains(trimmed);
  }

  /// Truncates to [maxLength] characters and appends `'...'`.
  String truncateWithEllipsis({required int maxLength}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}
