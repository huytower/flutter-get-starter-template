import 'package:auto_route/auto_route.dart';
import 'package:features/export_features.dart';
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
    AutoRoute(page: SplashRoute.page, path: AppRoute.splash.path),
    AutoRoute(page: LoginRoute.page, path: AppRoute.login.path),

    // --- Feature Modules (from package:features) ---
    AutoRoute(page: PhoneAuthRoute.page, path: AppRoute.phoneAuth.path),
    AutoRoute(page: DashboardRoute.page, path: AppRoute.dashboard.path),
    AutoRoute(page: CounterRoute.page, path: AppRoute.featuresCounter.path),
    AutoRoute(page: WebRoute.page, path: AppRoute.web.path),

    // --- GetX Examples & Pages ---
    AutoRoute(page: HomeRoute.page, path: AppRoute.home.path),
    AutoRoute(page: WalletRoute.page, path: AppRoute.wallet.path),
    AutoRoute(page: CommentRoute.page, path: AppRoute.comment.path),
    AutoRoute(page: CommentDetailRoute.page, path: AppRoute.commentDetail.path),

    // --- Bloc Examples ---
    AutoRoute(page: SimpleCubitRoute.page, path: ExampleRoute.blocSimple.path),
    AutoRoute(page: AdvanceBlocRoute.page, path: ExampleRoute.blocAdvance.path),
  ];
}
