import 'package:auto_route/auto_route.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_micro_features/export_micro_features.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthCoordinator)
class AuthCoordinatorImpl implements AuthCoordinator {
  @override
  void navigateToLogin(BuildContext context) {
    context.router.replace(LoginRoute());
  }

  @override
  void navigateToPhoneAuth(BuildContext context) {
    context.router.push(const PhoneAuthRoute());
  }

  @override
  void navigateToDashboard(BuildContext context) {
    context.router.replacePath(CcRouteConfig.mainNavigation);
  }
}
