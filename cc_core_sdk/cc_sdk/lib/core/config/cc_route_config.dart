import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized route configuration provider.
/// Reads route paths from environment variables to allow decoupling
/// between modules.
class CcRouteConfig {
  /// The path to the main navigation (home) screen.
  static String get mainNavigation =>
      dotenv.get('MAIN_NAVIGATION_PATH', fallback: '/main_navigation');

  /// The path to the login screen.
  static String get login => dotenv.get('LOGIN_PATH', fallback: '/login');
}
