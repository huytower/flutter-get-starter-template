import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import 'base_hero_banner_card.dart';

class LendHeroCard extends StatelessWidget {
  const LendHeroCard({
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
    final color = scheme.debtLoan.withValues(alpha: 0.7);

    return BaseHeroBannerCard(
      titleKey: CcLocaleKeys.liability_lend,
      balance: balance,
      subtitleKey: CcLocaleKeys.transaction_liability_category_lend_label,
      balanceIcon: Icons.handshake_outlined,
      bannerIcon: Icons.trending_up,
      color: color,
      isFront: isFront,
      onTap: onTap,
    );
  }
}
