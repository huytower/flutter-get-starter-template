abstract final class CurrencySelectionSources {
  static const detected = 'detected';
  static const userSelected = 'user_selected';
  static const migrated = 'migrated';

  /// Validates and normalizes selection source strings; defaults to [migrated] if invalid.
  static String validate(String? source) {
    if (source != null) {
      final normalized = source.toLowerCase().trim();
      if (normalized == detected ||
          normalized == userSelected ||
          normalized == migrated) {
        return normalized;
      }
    }
    return migrated;
  }
}

