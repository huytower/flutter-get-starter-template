import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'prj_merged_asset_loader.dart';

///
/// This class provides static methods to handle all localization needs,
/// including string translation, locale management, and supported locales.
class PrjLocalization {
  // Private constructor to prevent instantiation
  PrjLocalization._();

  /// The path to the directory containing the translation files.
  // In modules/message/lib/prj_localization.dart
  static const String translationsPath = 'packages/message/assets/translations';

  /// The fallback locale to use when a locale is not supported.
  static const Locale fallbackLocale = Locale('en');

  /// The list of supported locales in the application.
  static const List<Locale> supportedLocales = [
    Locale('vi'), // Vietnamese
    Locale('en'), // English
    Locale('ko'), // Korean
    Locale('ja'), // Japanese
    Locale('zh'), // Chinese
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
  ///
  /// [packageTranslations] are the `locale code -> translations` maps shipped
  /// by reusable packages (e.g. `CcMfTranslations.mapLocales` from
  /// cc_micro_features); they are merged under the app's own strings by
  /// [PrjMergedAssetLoader]. A key missing in the current locale falls back to
  /// [fallbackLocale].
  static Widget wrapWithLocalization({
    required Widget child,
    List<Map<String, Map<String, dynamic>>> packageTranslations = const [],
  }) {
    return EasyLocalization(
      path: translationsPath,
      supportedLocales: supportedLocales,
      fallbackLocale: fallbackLocale,
      useFallbackTranslations: true,
      startLocale: const Locale('en'),
      useOnlyLangCode: true,
      saveLocale: true,
      assetLoader: PrjMergedAssetLoader(
        packageTranslations: packageTranslations,
      ),
      child: child,
    );
  }

  /// Translates a string using the current locale.
  ///
  /// Example:
  /// ```dart
  /// PrjLocalization.translate('hello_world');
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
  /// await PrjLocalization.setLocale(context, const Locale('vi'));
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
      case 'ko':
        return '한국어';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Checks if the current locale is RTL.
  static bool hasRTL(BuildContext context) {
    return context.locale.languageCode == 'ar' ||
        context.locale.languageCode == 'he';
  }

  /// Plural translation with support for different counts.
  ///
  /// Example:
  /// ```dart
  /// PrjLocalization.plural('items_count', 5);
  /// ```
  static String plural(String key, num count, {List<String>? args}) {
    return key.plural(count.toDouble(), args: args);
  }

  /// Gets all available locales with their display names.
  static Map<Locale, String> getAvailableLocales() {
    return {
      const Locale('vi'): 'Tiếng Việt',
      const Locale('en'): 'English',
      const Locale('ko'): '한국어',
      const Locale('ja'): '日本語',
      const Locale('zh'): '中文',
      // Add more locales as needed
    };
  }
}
