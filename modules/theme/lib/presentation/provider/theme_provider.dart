import 'dart:ui';

import 'package:flutter/material.dart';

/// Manages the application's theme state and provides theme-related functionality
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  bool _followSystem = true;

  /// Gets the current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Checks if dark mode is currently active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Checks if the app is following system theme
  bool get followSystem => _followSystem;

  ThemeProvider({bool? initialDarkMode})
    : _themeMode = initialDarkMode != null
          ? (initialDarkMode ? ThemeMode.dark : ThemeMode.light)
          : _detectSystemTheme() {
    _followSystem =
        initialDarkMode == null; // Follow system only if no preference set
    _listenToSystemBrightnessChanges();
  }

  /// Detect system theme on initialization
  static ThemeMode _detectSystemTheme() {
    final platformBrightness = PlatformDispatcher.instance.platformBrightness;
    return platformBrightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  /// Listen to system brightness changes and automatically update theme
  void _listenToSystemBrightnessChanges() {
    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      if (_followSystem) {
        final newThemeMode = _detectSystemTheme();
        if (_themeMode != newThemeMode) {
          _themeMode = newThemeMode;
          notifyListeners();
        }
      }
    };
  }

  /// Toggles between light and dark theme modes
  /// When manually toggling, it stops following system theme
  void toggleTheme(bool isOn) {
    _followSystem = false; // Stop following system when manually toggled
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Sets the theme mode explicitly
  /// When explicitly set, it stops following system theme
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _followSystem = false; // Stop following system when explicitly set
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// Enable automatic system theme following
  void enableSystemThemeFollowing() {
    if (!_followSystem) {
      _followSystem = true;
      _themeMode = _detectSystemTheme();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Clean up the brightness change listener
    PlatformDispatcher.instance.onPlatformBrightnessChanged = null;
    super.dispose();
  }
}

/// Extension for accessing theme-related properties from BuildContext
extension ThemeUtils on BuildContext {
  /// Gets the current theme's color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Gets the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Gets the current brightness (light/dark)
  Brightness get brightness => Theme.of(this).brightness;
}
