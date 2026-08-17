import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import 'budget_hero_banner.dart';

/// Hero banner for liabilities (loans/debts) matching the design of BudgetHeroBanner.
class LiabilityHeroBanner extends StatelessWidget {
  const LiabilityHeroBanner({
    required this.walletController,
    required this.borrowBalance,
    required this.lendBalance,
    required this.totalBalance,
    super.key,
  });

  final WalletController walletController;
  final RxInt borrowBalance;
  final RxInt lendBalance;
  final RxInt totalBalance;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return BudgetHeroBanner(
      walletController: walletController,
      titleKey: CcLocaleKeys.wallet_liabilities,
      balance: totalBalance,
      subtitleKey: CcLocaleKeys.wallet_liabilities_desc,
      icon: Icons.warning_amber_rounded,
      color: CcBaseColors.violet500,
      topPadding: CcPaddingParams.SPACE_SM,
      bottomPadding: CcPaddingParams.SPACE_XS,
      leadingBalanceWidget: Icon(
        Icons.calculate_outlined,
        color: scheme.onPrimary.withOpacity(0.8),
        size: context.respIconSize(baseSize: 18),
      ),
      trailingBalanceWidget: Obx(() {
        final visible = walletController.isBalanceVisible.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniStat(
              context,
              icon: Icons.call_made_rounded,
              value: borrowBalance.value,
              visible: visible,
              color: scheme.onPrimary.withOpacity(0.7),
              isNegative: true,
            ),
            const SizedBox(width: 8),
            _buildMiniStat(
              context,
              icon: Icons.call_received_rounded,
              value: lendBalance.value,
              visible: visible,
              color: scheme.onPrimary.withOpacity(0.7),
              isNegative: false,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required IconData icon,
    required int value,
    required bool visible,
    required Color color,
    required bool isNegative,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: context.respIconSize(baseSize: 12), color: color),
        const SizedBox(width: 2),
        CcText(
          visible
              ? '${isNegative ? '-' : ''}${TransactionFormHelpers.formatShort(value)}'
              : '***',
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: CcTypographyParams.semiBold,
          ),
        ),
      ],
    );
  }
}
