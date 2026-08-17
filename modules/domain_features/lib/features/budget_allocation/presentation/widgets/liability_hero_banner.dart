import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Hero banner for liabilities (loans/debts) with a different design from
/// BudgetHeroBanner - shows debt breakdown with warning visual style.
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

    void _toggleVisibility() => walletController.isBalanceVisible.toggle();

    return CcPadding(
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CcBaseColors.violet500, CcBaseColors.violet600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: context.brXl,
          boxShadow: [
            BoxShadow(
              color: CcBaseColors.violet600.withOpacity(0.3),
              blurRadius: context.respDim(20),
              offset: Offset(0, context.respDim(8)),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
          vertical: context.respPadding(CcPaddingParams.SPACE_MD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.respDim(8)),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: scheme.onPrimary,
                        size: context.respIconSize(baseSize: 18),
                      ),
                    ),
                    const CcSpaceMD(),
                    CcText(
                      el.tr(CcLocaleKeys.wallet_liabilities),
                      textStyle: context.ccTextTheme.titleSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: CcTypographyParams.semiBold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.warning_amber_rounded,
                  color: scheme.onPrimary.withOpacity(0.8),
                  size: context.respIconSize(baseSize: 20),
                ),
              ],
            ),
            const CcSpaceLG(),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      context,
                      label: el.tr(CcLocaleKeys.loan_borrow),
                      balance: borrowBalance.value,
                      color: scheme.onPrimary,
                      isNegative: true,
                    ),
                  ),
                  Expanded(
                    child: _buildBalanceItem(
                      context,
                      label: el.tr(CcLocaleKeys.loan_lend),
                      balance: lendBalance.value,
                      color: scheme.onPrimary,
                      isNegative: false,
                    ),
                  ),
                ],
              ),
            ),
            const CcSpaceMD(),
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
                  vertical: context.respPadding(CcPaddingParams.SPACE_SM),
                ),
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CcText(
                      el.tr(CcLocaleKeys.wallet_liabilities_net),
                      textStyle: context.ccTextTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                    CcText(
                      walletController.isBalanceVisible.value
                          ? TransactionFormHelpers.formatShort(
                              totalBalance.value,
                            )
                          : '*********',
                      textStyle: context.ccTextTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: CcTypographyParams.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      CcPaddingParams.SPACE_XS, // bottom
      CcPaddingParams.SPACE_LG, // left
      CcPaddingParams.SPACE_LG, // right
      CcPaddingParams.SPACE_SM, // top
    );
  }

  Widget _buildBalanceItem(
    BuildContext context, {
    required String label,
    required int balance,
    required Color color,
    required bool isNegative,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CcText(
          label,
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.7),
          ),
        ),
        const CcSpaceXS(),
        Obx(
          () => CcText(
            '${isNegative ? '-' : ''}${walletController.isBalanceVisible.value ? TransactionFormHelpers.formatShort(balance) : '***'}',
            textStyle: context.ccTextTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: CcTypographyParams.bold,
            ),
          ),
        ),
      ],
    );
  }
}
