/// How this app's bundled legal HTML files (`assets/legal/*.html`) switch
/// language: each file holds English and Vietnamese and exposes
/// `showEnglish()` / `showVietnamese()`.
abstract final class LegalDocumentScripts {
  static const Map<String, String> byLanguage = {'vi': 'showVietnamese()'};

  /// Every other language reads the English text.
  static const String fallback = 'showEnglish()';
}
