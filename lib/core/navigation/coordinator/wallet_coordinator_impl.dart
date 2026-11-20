import 'package:auto_route/auto_route.dart';
import 'package:domain_features/core/navigation/coordinator/wallet_coordinator.dart';
import 'package:domain_features/core/navigation/domain_router.gr.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WalletCoordinator)
class WalletCoordinatorImpl implements WalletCoordinator {
  @override
  void navigateBack(BuildContext context) {
    context.router.back();
  }

  @override
  void navigateToWalletDetail(BuildContext context, WalletEntity wallet) {
    context.pushRoute(WalletDetailRoute(wallet: wallet));
  }
}
