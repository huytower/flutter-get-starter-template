import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final loan = balance.liability;
    final isSettled = balance.status == LiabilityStatus.settled;
    final directionColor = context.ccColorScheme.primary;

    return CcBouncing(
      onTap: onTap,
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          Container(
            width: context.respDim(160),
            padding: EdgeInsets.symmetric(
              horizontal: context.respDim(12),
              vertical: context.respDim(8),
            ),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: context.brLg,
              border: Border.all(
                color: scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned.fill(child: CcGlassyGradientIcon()),
                          CcIconToken(
                            iconDataFromCode(
                              loan.categoryIconCode ?? 0,
                              fontFamily: loan.categoryIconFamily,
                            ),
                            size: 16,
                            color: directionColor,
                          ),
                        ],
                      ),
                    ),
                    const CcSpaceSM(),
                    Expanded(
                      child: CcText(
                        loan.categoryLabel,
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
                CcDividerLine(
                  color: scheme.onSurface.withOpacity(0.06),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCompactStat(
                      context,
                      icon: loan.isBorrow
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: isSettled
                          ? scheme.onSurfaceVariant
                          : directionColor,
                      value: balance.outstandingBalance,
                    ),
                    _buildCompactStat(
                      context,
                      icon: Icons.eco_outlined,
                      color: scheme.onSurfaceVariant,
                      value: loan.principalAmount,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required int value,
  }) {
    final controller = Get.find<WalletController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: context.respIconSize(baseSize: 12),
          color: color.withOpacity(0.8),
        ),
        const SizedBox(width: 4),
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
