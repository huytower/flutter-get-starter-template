import 'package:flutter/material.dart';

/// Extension on BuildContext to easily access project-standard theme properties.
///
/// This provides a state-management and font-agnostic way for widgets in the
/// UI library to synchronize with the application's theme.
extension CcContextExtension on BuildContext {
  /// Access the Material TextTheme.
  TextTheme get ccTextTheme => Theme.of(this).textTheme;

  /// Access the Material ColorScheme.
  ColorScheme get ccColorScheme => Theme.of(this).colorScheme;

  /// Access the overall Theme.
  ThemeData get ccTheme => Theme.of(this);

  /// Check if the current theme is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
