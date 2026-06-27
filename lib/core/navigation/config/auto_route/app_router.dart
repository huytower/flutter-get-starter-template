import 'package:auto_route/auto_route.dart';
import 'package:cc_micro_features/export_micro_features.dart';
import 'package:domain_features/core/navigation/domain_router.gr.dart';
import 'package:injectable/injectable.dart';

import '../../route_names.dart';
import 'app_router.gr.dart';

/// Centralized router configuration for the application.
///
/// This class uses auto_route for type-safe navigation and route generation.
/// Routes are organized into logical groups for better maintainability.
@lazySingleton
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
    // --- Auth Routes (from cc_micro_features) ---
    AutoRoute(page: LoginRoute.page, path: AppRoute.login.path),
    AutoRoute(page: PhoneAuthRoute.page, path: AppRoute.phoneAuth.path),
    AutoRoute(
      page: OtpVerificationRoute.page,
      path: AppRoute.otpVerification.path,
    ),
    AutoRoute(page: SplashRoute.page, path: AppRoute.splash.path),
    AutoRoute(page: WebRoute.page, path: AppRoute.web.path),

    // --- GetX Examples & Pages ---
    AutoRoute(page: HomeRoute.page, path: AppRoute.home.path),
    AutoRoute(page: CommentRoute.page, path: AppRoute.comment.path),
    AutoRoute(page: CommentDetailRoute.page, path: AppRoute.commentDetail.path),

    // --- Bloc Examples ---
    AutoRoute(page: SimpleCubitRoute.page, path: ExampleRoute.blocSimple.path),
    AutoRoute(page: AdvanceBlocRoute.page, path: ExampleRoute.blocAdvance.path),
  ];
}
