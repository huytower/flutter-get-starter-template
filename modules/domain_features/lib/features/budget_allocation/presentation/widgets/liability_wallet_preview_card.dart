import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/category_name_util.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../liability/domain/entities/liability_balance_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Compact horizontal card for a liability (loan) shown on the dashboard.
class LiabilityWalletPreviewCard extends StatelessWidget {
  const LiabilityWalletPreviewCard({
    super.key,
    required this.balance,
    required this.onTap,
  });

  final LiabilityBalanceEntity balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final liability = balance.liability;
    final directionColor = context.ccColorScheme.primary;

    return CcBouncing(
      onTap: onTap,
      borderRadius: context.brLg,
      child: Container(
        width: context.respDim(160),
        padding: EdgeInsets.symmetric(
          horizontal: context.respDim(12),
          vertical: context.respDim(8),
        ),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.1),
          borderRadius: context.brLg,
          border: context.borderSubtle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: context.respDim(28),
                  height: context.respDim(28),
                  decoration: BoxDecoration(
                    color: directionColor.withAlpha(20),
                    borderRadius: context.brLg,
                  ),
                  child: Center(
                    child: CcIconToken(
                      iconDataFromCode(
                        liability.categoryIconCode ?? 0,
                        fontFamily: liability.categoryIconFamily,
                      ),
                      size: 16,
                      color: directionColor,
                    ),
                  ),
                ),
                const CcSpaceSM(),
                Expanded(
                  child: CcText(
                    CategoryNameUtil.getLocalizedName(
                      liability.categoryLabel,
                      liability.categoryNameKey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      fontWeight: CcTypographyParams.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            CcDividerLine(color: scheme.onSurface.withOpacity(0.06)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCompactStat(
                  context,
                  color: directionColor,
                  iconAsset: liability.isBorrow
                      ? 'assets/icon/ic_borrow.webp'
                      : 'assets/icon/ic_lend.webp',
                  value: liability.principalAmount,
                ),
                _buildCompactStat(
                  context,
                  iconAsset: liability.isBorrow
                      ? 'assets/icon/ic_repay.webp'
                      : 'assets/icon/ic_collect.webp',
                  color: context.ccColorScheme.onSurface,
                  value: liability.principalAmount - balance.outstandingBalance,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context, {
    required String iconAsset,
    required Color color,
    required int value,
  }) {
    final controller = Get.find<WalletController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconAsset,
          color: color.withOpacity(0.8),
          width: context.respIconSize(baseSize: 24),
          height: context.respIconSize(baseSize: 24),
        ),
        const CcSpaceXS(),
        Obx(
          () => CcText(
            controller.isBalanceVisible.value
                ? TransactionFormHelpers.formatShort(value)
                : '*****',
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: CcTypographyParams.semiBold,
              fontSize: context.respFontSize(10),
            ),
          ),
        ),
      ],
    );
  }
}
