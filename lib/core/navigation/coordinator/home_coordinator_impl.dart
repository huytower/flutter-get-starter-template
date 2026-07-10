import 'package:auto_route/auto_route.dart';
import 'package:cc_bridge/export_cc_bridge.dart';
import 'package:cc_micro_features/export_micro_features.dart';
import 'package:domain_features/core/navigation/domain_router.gr.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HomeCoordinator)
class HomeCoordinatorImpl implements HomeCoordinator {
  @override
  void navigateToWeb(
    BuildContext context, {
    required String url,
    String? title,
  }) {
    context.router.push(const WebRoute());
  }

  @override
  void navigateToWallet(BuildContext context) {
    context.router.push(const WalletRoute());
  }

  @override
  void navigateToTransaction(BuildContext context) {
    context.router.push(TransactionRoute());
  }
}
