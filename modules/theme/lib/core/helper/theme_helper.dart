import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../data/data_source/color/prj_color.dart';
import '../../presentation/style/cc_text_style.dart';

/// Creates a `ColorScheme` based on the provided `brightness`.
///
/// This helper centralizes how semantic `PrjColors` are mapped into the
/// `ColorScheme` consumed by `ThemeData`. Widgets should read colors from
/// `Theme.of(context).colorScheme` to remain decoupled from the color source.
ColorScheme createColorScheme(Brightness brightness) {
  final baseScheme = brightness == Brightness.dark
      ? const ColorScheme.dark()
      : const ColorScheme.light();

  return baseScheme.copyWith(
    primary: PrjColors.primary,
    primaryContainer: PrjColors.primaryContainer,
    onPrimary: PrjColors.onPrimary,
    onPrimaryContainer: PrjColors.onPrimaryContainer,
    secondary: PrjColors.secondary,
    secondaryContainer: PrjColors.secondaryContainer,
    onSecondary: PrjColors.onSecondary,
    onSecondaryContainer: PrjColors.onSecondaryContainer,
    surface: PrjColors.surface,
    surfaceVariant: PrjColors.surfaceVariant,
    background: PrjColors.background,
    error: PrjColors.error,
    onSurface: PrjColors.onSurface,
    onSurfaceVariant: PrjColors.onSurfaceVariant,
    onBackground: PrjColors.onBackground,
    onError: PrjColors.onError,
    brightness: brightness,
  );
}

/// Returns the list of supported localization delegates
List<LocalizationsDelegate> getLocalizationDelegates() {
  return const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

/// Returns the list of supported locales
List<Locale> getSupportedLocales() {
  return const [
    Locale('en', ''), // English, no country code
  ];
}

/// Creates a light theme configuration
ThemeData createLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: createColorScheme(Brightness.light),
    extensions: <ThemeExtension<dynamic>>[CcTextStyle.light()],
  );
}

/// Creates a dark theme configuration
ThemeData createDarkTheme() {
  return ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: createColorScheme(Brightness.dark),
    extensions: <ThemeExtension<dynamic>>[CcTextStyle.dark()],
  );
}
