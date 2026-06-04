import 'package:flutter/material.dart';

/// Typography design tokens for the `cc_sdk_ui` library.
///
/// Purpose:
/// - Provide a Single Source of Truth (SSOT) for typography values (weights,
///   sizes and letter spacing) used across the UI SDK and app themes.
/// - Keep these values compile-time constant to match design tokens from Figma
///   and to improve performance.
///
/// Usage:
/// 1. Import from the SDK:
///
/// ```dart
/// import 'package:cc_sdk_ui/core/config/tokens/cc_typography_params.dart';
/// ```
///
/// 2. Use the tokens directly in `TextStyle` or theme definitions:
///
/// ```dart
/// Text(
///   'Title',
///   style: TextStyle(
///     fontSize: CcTypographyParams.titleLarge,
///     fontWeight: CcTypographyParams.medium,
///   ),
/// )
/// ```
///
/// 3. In `cc_text_style.dart` the library already uses these constants to
///    build consumable `ThemeExtension` text styles. Prefer using the
///    semantic `TextTheme` (from `Theme.of(context)`) in widgets instead of
///    hardcoding sizes.
///
/// Notes:
/// - Keep this file small and focused on design token values only. Behavioral
///   or platform-specific adjustments should happen in theme files.

abstract class CcTypographyParams {
  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Font sizes (logical pixels)
  static const double displayLarge =
      57; // displayLarge: page-level or hero headings, very large font-size (high visual priority).
  static const double displayMedium = 45;
  static const double displaySmall = 36;
  static const double headlineLarge = 32;
  static const double headlineMedium = 28;
  static const double headlineSmall = 24;
  static const double titleLarge = 22;
  static const double titleMedium = 16;
  static const double titleSmall = 14;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelLarge =
      14; // labelLarge: UI control label (buttons, chips), small compact text meant to sit inside controls.
  static const double labelMedium = 12;
  static const double labelSmall = 11;
}
