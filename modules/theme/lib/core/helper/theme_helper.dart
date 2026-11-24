import 'package:flutter/material.dart';

import '../../presentation/style/prj_colors.dart';
import '../../presentation/style/prj_text_style.dart';

/// Creates a `ColorScheme` based on the provided `brightness`.
///
/// This helper centralizes how semantic `PrjColors` are mapped into the
/// `ColorScheme` consumed by `ThemeData`. Widgets should read colors from
/// `Theme.of(context).colorScheme` to remain decoupled from the color source.
ColorScheme createColorScheme(Brightness brightness) {
  final bool hasDark = brightness == Brightness.dark;
  final baseScheme = hasDark
      ? const ColorScheme.dark()
      : const ColorScheme.light();

  return baseScheme.copyWith(
    primary: PrjColors.primary,
    primaryContainer: hasDark
        ? PrjColors.darkPrimaryContainer
        : PrjColors.primaryContainer,
    onPrimary: PrjColors.onPrimary,
    onPrimaryContainer: PrjColors.onPrimaryContainer,
    secondary: PrjColors.secondary,
    secondaryContainer: PrjColors.secondaryContainer,
    onSecondary: PrjColors.onSecondary,
    onSecondaryContainer: PrjColors.onSecondaryContainer,
    surface: hasDark ? PrjColors.darkSurface : PrjColors.surface,
    surfaceVariant: hasDark
        ? PrjColors.darkSurfaceVariant
        : PrjColors.surfaceVariant,
    background: hasDark ? PrjColors.darkBackground : PrjColors.background,
    error: PrjColors.error,
    onSurface: hasDark ? PrjColors.darkOnSurface : PrjColors.onSurface,
    onSurfaceVariant: hasDark
        ? PrjColors.darkOnSurfaceVariant
        : PrjColors.onSurfaceVariant,
    onBackground: hasDark ? PrjColors.darkOnBackground : PrjColors.onBackground,
    onError: PrjColors.onError,
    brightness: brightness,
  );
}

/// Creates a light theme configuration
ThemeData createLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: createColorScheme(Brightness.light),
    extensions: <ThemeExtension<dynamic>>[PrjTextStyle.light()],
  );
}

/// Creates a dark theme configuration
ThemeData createDarkTheme() {
  return ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: createColorScheme(Brightness.dark),
    extensions: <ThemeExtension<dynamic>>[PrjTextStyle.dark()],
  );
}
