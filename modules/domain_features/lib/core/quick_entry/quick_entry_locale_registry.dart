import 'package:intl/intl.dart';

import 'quick_entry_locale_pack.dart';

/// Single access point for language-sensitive local quick-entry content.
abstract final class QuickEntryLocaleRegistry {
  QuickEntryLocaleRegistry._();

  static final QuickEntryLocalePack _vietnamese =
      QuickEntryLocalePack.vietnamese();

  /// Supported app regions. Packs without converted content intentionally fall
  /// back to Vietnamese until their region-specific dataset is added.
  static const supportedLanguageCodes = {'vi', 'en', 'ko', 'ja', 'zh'};

  static QuickEntryLocalePack get current {
    final languageCode = Intl.getCurrentLocale().split('_').first.toLowerCase();
    return byLanguageCode(languageCode);
  }

  static QuickEntryLocalePack byLanguageCode(String? languageCode) {
    // Phase 1 keeps behavior stable: all non-Vietnamese regions use the
    // existing Vietnamese dataset until their packs are populated.
    switch (languageCode?.toLowerCase()) {
      case 'vi':
      case 'en':
      case 'ko':
      case 'ja':
      case 'zh':
      default:
        return _vietnamese;
    }
  }
}
