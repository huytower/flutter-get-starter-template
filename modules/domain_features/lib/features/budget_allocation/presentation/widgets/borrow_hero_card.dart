import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import 'base_hero_banner_card.dart';

class BorrowHeroCard extends StatelessWidget {
  const BorrowHeroCard({
    required this.walletController,
    required this.balance,
    required this.isFront,
    this.onTap,
    super.key,
  });

  final WalletController walletController;
  final int balance;
  final bool isFront;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return BaseHeroBannerCard(
      titleKey: CcLocaleKeys.wallet_liabilities,
      balance: balance,
      subtitleKey: CcLocaleKeys.wallet_liabilities_desc,
      balanceIcon: Icons.waving_hand,
      bannerIcon: Icons.warning_amber_rounded,
      color: scheme.debtLoan,
      isFront: isFront,
      onTap: onTap,
    );
  }
}
