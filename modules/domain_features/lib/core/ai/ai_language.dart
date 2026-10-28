import 'package:message/cc_localization.dart';

abstract final class AiLanguage {
  AiLanguage._();

  static const Map<String, String> _names = {
    'vi': 'Vietnamese',
    'en': 'English',
    'ko': 'Korean',
    'ja': 'Japanese',
    'zh': 'Chinese',
  };

  static String nameOf(String? languageCode) {
    final code = (languageCode ?? CcLocalization.fallbackLocale.languageCode)
        .toLowerCase();
    return _names[code] ?? code;
  }
}
