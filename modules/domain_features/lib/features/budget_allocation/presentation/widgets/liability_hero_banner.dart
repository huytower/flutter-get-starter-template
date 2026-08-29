import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import 'liquid_hero_banner.dart';

/// Hero banner for liabilities (loans/debts) matching the design of LiquidHeroBanner.
class LiabilityHeroBanner extends StatelessWidget {
  const LiabilityHeroBanner({
    required this.walletController,
    required this.borrowBalance,
    required this.lendBalance,
    required this.totalBalance,
    this.onTap,
    super.key,
  });

  final WalletController walletController;
  final RxInt borrowBalance;
  final RxInt lendBalance;
  final RxInt totalBalance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return LiquidHeroBanner(
      walletController: walletController,
      titleKey: CcLocaleKeys.wallet_liabilities,
      balance: borrowBalance,
      subtitleKey: CcLocaleKeys.wallet_liabilities_desc,
      icon: Icons.warning_amber_rounded,
      color: CcBaseColors.violet500,
      topPadding: CcPaddingParams.SPACE_SM,
      bottomPadding: CcPaddingParams.SPACE_XS,
      onTap: onTap,
      leadingBalanceWidget: Icon(
        Icons.waving_hand,
        color: scheme.onPrimary.withOpacity(0.8),
        size: context.respIconSize(baseSize: 18),
      ),
      trailingBalanceWidget: Obx(() {
        final visible = walletController.isBalanceVisible.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: context.respIconSize(baseSize: 14),
              color: scheme.onPrimary.withOpacity(0.9),
            ),
            const SizedBox(width: 4),
            CcText(
              visible
                  ? TransactionFormHelpers.formatShort(lendBalance.value)
                  : '***',
              textStyle: context.ccTextTheme.titleSmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: CcTypographyParams.bold,
              ),
            ),
          ],
        );
      }),
    );
  }
}
