/// Kotlin-style scope helpers for configuring objects inline.
///
/// Example:
/// ```dart
/// MyModel().apply((it) => it.value = 'updated');
/// list.takeIf((it) => it.length > 2)?.apply((it) => print(it.length));
/// ```
extension CcScopeExtension<T> on T {
  /// Runs [block] with `this` as receiver and returns `this`.
  T apply(void Function(T self) block) {
    block(this);
    return this;
  }

  /// Returns `this` when [predicate] is true, otherwise `null`.
  T? takeIf(bool Function(T self) predicate) => predicate(this) ? this : null;
}
