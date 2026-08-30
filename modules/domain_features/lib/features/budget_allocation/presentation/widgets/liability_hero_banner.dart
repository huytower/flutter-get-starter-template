import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Hero banner specialized for liabilities (loans/debts).
/// Decoupled from LiquidHeroBanner to handle its own layout and logic for
/// multiple balances (Borrow vs. Lend).
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
    final color = scheme.debtLoan;

    return CcPadding(
      CcBouncing(
        onTap: onTap,
        borderRadius: context.brXl,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: context.brXl,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: context.respDim(20),
                offset: Offset(0, context.respDim(10)),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
            vertical: context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CcText(
                      el.tr(CcLocaleKeys.wallet_liabilities),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: scheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                    const CcSpaceXS(),
                    Obx(
                      () => Row(
                        children: [
                          Icon(
                            Icons.waving_hand,
                            color: scheme.onPrimary.withOpacity(0.8),
                            size: context.respIconSize(baseSize: 18),
                          ),
                          const SizedBox(width: 4),
                          CcText(
                            walletController.isBalanceVisible.value
                                ? TransactionFormHelpers.formatShort(
                                    borrowBalance.value,
                                  )
                                : '*********',
                            textStyle: context.ccTextTheme.headlineMedium
                                ?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: CcTypographyParams.bold,
                                  letterSpacing: 0.2,
                                ),
                          ),
                          const CcSpaceMD(),
                          _buildLendStats(context),
                        ],
                      ),
                    ),
                    const CcSpaceXS(),
                    CcText(
                      el.tr(CcLocaleKeys.wallet_liabilities_desc),
                      maxLines: 2,
                      textStyle: context.ccTextTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const CcSpaceLG(),
              Container(
                padding: EdgeInsets.all(context.respDim(6)),
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CcIconToken(
                  Icons.warning_amber_rounded,
                  color: scheme.onPrimary,
                  size: context.respIconSize(baseSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      CcPaddingParams.SPACE_XS, // bottom
      CcPaddingParams.SPACE_LG, // left
      CcPaddingParams.SPACE_LG, // right
      CcPaddingParams.SPACE_SM, // top
    );
  }

  Widget _buildLendStats(BuildContext context) {
    final scheme = context.ccColorScheme;
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
  }
}
