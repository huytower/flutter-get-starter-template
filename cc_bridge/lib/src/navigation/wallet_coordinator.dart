import 'package:flutter/widgets.dart';

import 'package:domain_features/features/wallet/domain/entities/wallet_entity.dart';

/// Contract for Wallet-related navigation.
abstract class WalletCoordinator {
  /// Navigates back from wallet.
  void navigateBack(BuildContext context);

  /// Navigates to wallet detail.
  void navigateToWalletDetail(BuildContext context, WalletEntity wallet);
}
