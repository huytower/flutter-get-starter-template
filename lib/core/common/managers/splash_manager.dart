import 'package:shared_preferences/shared_preferences.dart';

class SplashManager {
  static const String _lastSplashShownKey = 'last_splash_shown';
  static const Duration _splashInterval = Duration(days: 7);

  /// Check if splash screen should be shown
  static Future<bool> shouldShowSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt(_lastSplashShownKey);

    if (lastShown == null) {
      // First time showing splash
      await _markSplashShown();
      return true;
    }

    final lastShownDate = DateTime.fromMillisecondsSinceEpoch(lastShown);
    final now = DateTime.now();
    final difference = now.difference(lastShownDate);

    if (difference >= _splashInterval) {
      await _markSplashShown();
      return true;
    }

    return false;
  }

  /// Mark that splash screen was shown
  static Future<void> _markSplashShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastSplashShownKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Reset splash screen timer (for testing purposes)
  static Future<void> resetSplashTimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSplashShownKey);
  }
}
