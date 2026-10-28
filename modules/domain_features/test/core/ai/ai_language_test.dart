import 'package:domain_features/core/ai/ai_language.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message/cc_localization.dart';

void main() {
  group('AiLanguage.nameOf', () {
    test('names every language the app supports', () {
      for (final locale in CcLocalization.supportedLocales) {
        expect(
          AiLanguage.nameOf(locale.languageCode),
          isNot(locale.languageCode),
          reason: '${locale.languageCode} has no English name for the prompt',
        );
      }
    });

    test('is case-insensitive', () {
      expect(AiLanguage.nameOf('KO'), 'Korean');
    });

    test('falls back to the app default language when none is given', () {
      expect(AiLanguage.nameOf(null), 'Vietnamese');
    });

    test('keeps an unmapped language code as is', () {
      expect(AiLanguage.nameOf('fr'), 'fr');
    });
  });
}
