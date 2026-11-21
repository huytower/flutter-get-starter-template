/// Paths of the App Shell routes that code outside `lib/` must reach.
///
/// `MainNavigationRoute` and `LoginRoute` live in the shell, which the bridge
/// cannot import, so the shell registers them under these paths and the bridge
/// navigates by path (the one string-path hop, see `AuthCoordinatorImpl`).
abstract final class ShellRoutePaths {
  ShellRoutePaths._();

  /// The main navigation (home) screen.
  static const String mainNavigation = '/main_navigation';

  /// The login screen.
  static const String login = '/login';
}
