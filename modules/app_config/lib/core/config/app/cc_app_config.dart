import 'package:package_info_plus/package_info_plus.dart';

class CcAppConfig {
  /// Creates a new immutable configuration instance.
  const CcAppConfig();

  // Version Information

  /// Gets the current app version from pubspec.yaml
  ///
  /// Format: x.y.z+hotfix
  static Future<String> get version async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Gets the current build number from pubspec.yaml
  ///
  /// This is the number after the + in the version
  static Future<String> get buildNumber async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  /// Gets the semantic version (x.y.z) without build number
  static Future<String> get semanticVersion async {
    final v = await version;
    return v.split('+').first;
  }

  /// The current iOS app version.
  ///
  /// This should match the version in pubspec.yaml
  static Future<int> get iosVersion async {
    final version = await semanticVersion;
    final parts = version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    // Convert x.y.z to a single number (e.g., 1.2.3 -> 1002003)
    return parts[0] * 1000000 +
        (parts.length > 1 ? parts[1] * 1000 : 0) +
        (parts.length > 2 ? parts[2] : 0);
  }

  /// The current Android version code.
  ///
  /// This should match the build number in pubspec.yaml
  static Future<int> get androidVersionCode async {
    final buildNum = await buildNumber;
    return int.tryParse(buildNum) ?? 1;
  }

  /// The current Android version name.
  ///
  /// This should match the version in pubspec.yaml
  static Future<String> get androidVersionName async {
    return await semanticVersion;
  }

  /// For backward compatibility
  @Deprecated('Use iosVersion instead')
  static const VERSION_IOS = 1;

  /// For backward compatibility
  @Deprecated('Use androidVersionCode instead')
  static const VERSION_ANDROID = 1;
}
