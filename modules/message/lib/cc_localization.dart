import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

export 'localization_extension.dart';

/// A centralized localization service for the application.
///
/// This class provides static methods to handle all localization needs,
/// including string translation, locale management, and supported locales.
class CcLocalization {
  // Private constructor to prevent instantiation
  CcLocalization._();

  /// The path to the directory containing the translation files.
  // In modules/message/lib/cc_localization.dart
  static const String translationsPath = 'packages/message/assets/translations';

  /// The fallback locale to use when a locale is not supported.
  static const Locale fallbackLocale = Locale('en');

  /// The list of supported locales in the application.
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('vi'), // Vietnamese
    // Add more locales as needed
  ];

  /// Initializes the localization service.
  ///
  /// This should be called before [runApp] in the [main] function.
  static Future<void> initialize() async {
    // Disable EasyLocalization debug logs
    EasyLocalization.logger.enableLevels = []; // This disables all logs
    await EasyLocalization.ensureInitialized();
  }

  /// Wraps the app with [EasyLocalization] to enable localization.
  static Widget wrapWithLocalization({required Widget child}) {
    return EasyLocalization(
      path: translationsPath,
      supportedLocales: supportedLocales,
      fallbackLocale: fallbackLocale,
      startLocale: fallbackLocale,
      useOnlyLangCode: true,
      saveLocale: true,
      child: child,
    );
  }

  /// Translates a string using the current locale.
  ///
  /// Example:
  /// ```dart
  /// CcLocalization.translate('hello_world');
  /// ```
  static String translate(
    String key, {
    List<String>? args,
    Map<String, String>? namedArgs,
  }) {
    if (args != null) {
      return key.tr(args: args);
    } else if (namedArgs != null) {
      return key.tr(namedArgs: namedArgs);
    }
    return key.tr();
  }

  /// Changes the app's locale.
  ///
  /// Example:
  /// ```dart
  /// await CcLocalization.setLocale(context, const Locale('vi'));
  /// ```
  static Future<void> setLocale(BuildContext context, Locale newLocale) async {
    await context.setLocale(newLocale);
  }

  /// Gets the current locale.
  static Locale getCurrentLocale(BuildContext context) {
    return context.locale;
  }

  /// Gets the display name of the current locale.
  static String getCurrentLanguageName(BuildContext context) {
    final locale = context.locale;
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Checks if the current locale is RTL.
  static bool isRTL(BuildContext context) {
    return context.locale.languageCode == 'ar' ||
        context.locale.languageCode == 'he';
  }

  /// Plural translation with support for different counts.
  ///
  /// Example:
  /// ```dart
  /// CcLocalization.plural('items_count', 5);
  /// ```
  static String plural(String key, num count, {List<String>? args}) {
    return key.plural(count.toDouble(), args: args);
  }

  /// Gets all available locales with their display names.
  static Map<Locale, String> getAvailableLocales() {
    return {
      const Locale('en'): 'English',
      const Locale('vi'): 'Tiếng Việt',
      // Add more locales as needed
    };
  }
}
