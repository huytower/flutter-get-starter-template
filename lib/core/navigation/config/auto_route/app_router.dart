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
    AutoRoute(page: BudgetAllocationRoute.page, path: AppRoute.wallet.path),
    AutoRoute(page: LiquidWalletListRoute.page, path: AppRoute.walletList.path),
    AutoRoute(page: WalletDetailRoute.page, path: AppRoute.walletDetail.path),
    AutoRoute(page: TransactionRoute.page, path: AppRoute.transaction.path),
    AutoRoute(page: CommentRoute.page, path: AppRoute.comment.path),
    AutoRoute(page: CommentDetailRoute.page, path: AppRoute.commentDetail.path),
    AutoRoute(page: BudgetLimitListRoute.page, path: AppRoute.budgetLimit.path),
    AutoRoute(page: ReconcileRoute.page, path: AppRoute.reconcile.path),
    AutoRoute(page: LiabilityListRoute.page, path: AppRoute.liabilityList.path),
    AutoRoute(
      page: LiabilityDetailRoute.page,
      path: AppRoute.liabilityDetail.path,
    ),
    AutoRoute(page: ReportRoute.page, path: AppRoute.report.path),
    AutoRoute(
      page: TermsOfServiceRoute.page,
      path: AppRoute.termsOfService.path,
    ),
    AutoRoute(
      page: InvestmentListRoute.page,
      path: AppRoute.investmentList.path,
    ),

    // --- Bloc Examples ---
    AutoRoute(page: SimpleCubitRoute.page, path: ExampleRoute.blocSimple.path),
    AutoRoute(page: AdvanceBlocRoute.page, path: ExampleRoute.blocAdvance.path),
  ];
}
