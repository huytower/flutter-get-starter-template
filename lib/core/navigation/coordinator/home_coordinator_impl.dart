import 'package:auto_route/auto_route.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:features/export_features.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HomeCoordinator)
class HomeCoordinatorImpl implements HomeCoordinator {
  @override
  void navigateToCounter(BuildContext context) {
    context.router.push(const CounterRoute());
  }

  @override
  void navigateToWeb(
    BuildContext context, {
    required String url,
    String? title,
  }) {
    context.router.push(const WebRoute());
  }
}
