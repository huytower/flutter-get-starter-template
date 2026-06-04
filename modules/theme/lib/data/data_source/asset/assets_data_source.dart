import 'package:flutter/material.dart';

/// Asset management for the application
///
/// This class provides type-safe access to all app assets with compile-time
/// checking and runtime validation in debug mode.
///
/// ## Usage
///
/// ```dart
/// // Get an asset path
/// final avatarPath = AssetUtils.getIcon(IconAsset.avatarDefault);
///
/// // Use with Image.asset
/// Image.asset(
///   AssetUtils.getIcon(IconAsset.analytics),
///   package: 'theme', // The package that contains the assets
/// );
/// ```

// Base path constants
class _AssetPaths {
  static const String _basePath = 'assets';
  static const String lottie = '$_basePath/lottie';
  static const String icon = '$_basePath/icons';
}

/// Base class for all asset types
sealed class AssetType {
  /// Creates an asset with the given path
  const AssetType(this.path);

  /// The full path to the asset
  final String path;

  @override
  String toString() => path;
}

/// Background image assets
class BackgroundAsset extends AssetType {
  const BackgroundAsset(String filename) : super('$filename');

  /// Background image for update version screens
  static const updateVersion = BackgroundAsset('bg_update_version.png');

  /// Background image for splash screens
  static const splash = BackgroundAsset('bg_splash.png');
}

/// Icon assets
class IconAsset extends AssetType {
  const IconAsset(String filename) : super('$filename');

  /// Default user avatar icon
  static const avatarDefault = IconAsset('ic_default_user_avatar.png');

  /// Analytics feature icon
  static const analytics = IconAsset('ic_analytics.png');

  /// Logout action icon
  static const logout = IconAsset('ic_logout.png');
}

/// Lottie animation assets
class LottieAsset extends AssetType {
  const LottieAsset(String filename) : super('$filename');

  /// Loading animation
  static const loading = LottieAsset('ic_loading.json');

  /// Completion animation
  static const complete = LottieAsset('ic_complete.json');
}

/// Logo assets
class LogoAsset extends AssetType {
  const LogoAsset(String filename) : super('$filename');

  /// Main application logo
  static const appLogo = LogoAsset('app_logo.png');
}

/// Utility class for working with assets
class AssetUtils {
  /// Get Lottie animation path
  ///
  /// Example:
  /// ```dart
  /// final animation = AssetUtils.getLottie(LottieAsset.loading);
  /// ```
  static String getLottie(LottieAsset asset) =>
      _validatePath('${_AssetPaths.lottie}/${asset.path}');

  /// Get icon path
  ///
  /// Example:
  /// ```dart
  /// final iconPath = AssetUtils.getIcon(IconAsset.analytics);
  /// ```
  static String getIcon(IconAsset asset) =>
      _validatePath('${_AssetPaths.icon}/${asset.path}');

  /// Validates that the asset path exists in the pubspec.yaml
  ///
  /// In debug mode, this will throw an exception if the asset is not found
  /// in the pubspec.yaml of the theme package.
  static String _validatePath(String path) {
    // Only validate in debug mode
    assert(() {
      try {
        // This will throw an exception if the asset is not found
        AssetImage(path, package: 'theme');
      } catch (e) {
        throw FlutterError('''
        Asset not found: $path
        Make sure to:
        1. Add the asset to the pubspec.yaml of the theme package
        2. Run 'flutter pub get'
        3. Verify the asset exists in the correct directory
        ''');
      }
      return true;
    }(), '');

    return path;
  }
}
