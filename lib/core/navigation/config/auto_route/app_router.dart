import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import '../../route_names.dart';
import 'app_router.gr.dart';

/// Centralized router configuration for the application.
///
/// This class uses auto_route for type-safe navigation and route generation.
/// Routes are organized into logical groups for better maintainability.
@singleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // --- Main App Shell & Core ---
    AutoRoute(
      page: NavigationBar.page,
      initial: true,
      path: AppRoute.mainNavigation.path,
    ),
  ];
}
