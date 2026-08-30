import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../get_x/budget_allocation_controller.dart';

/// Specialized card for Lend/Collect shown in the Liability Hero Banner.
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
    final controller = Get.find<BudgetAllocationController>();
    final scheme = context.ccColorScheme;
    final color = scheme.primary;

    return CcBouncing(
      onTap: isFront ? onTap : controller.toggleLiabilityCardStack,
      borderRadius: context.brXl,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
          vertical: context.respPadding(CcPaddingParams.SPACE_LG),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: context.brXl,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isFront ? 0.25 : 0.1),
              blurRadius: context.respDim(20),
              offset: Offset(0, context.respDim(10)),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CcText(
                    el.tr(CcLocaleKeys.liability_lend),
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary.withOpacity(0.85),
                    ),
                  ),
                  const CcSpaceXS(),
                  Row(
                    children: [
                      Icon(
                        Icons.handshake_outlined,
                        color: scheme.onPrimary.withOpacity(0.8),
                        size: context.respIconSize(baseSize: 18),
                      ),
                      const SizedBox(width: 4),
                      CcText(
                        walletController.isBalanceVisible.value
                            ? TransactionFormHelpers.formatShort(balance)
                            : '*********',
                        textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: CcTypographyParams.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const CcSpaceXS(),
                  CcText(
                    el.tr(
                      CcLocaleKeys.transaction_liability_category_lend_label,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: context.ccTextTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const CcSpaceLG(),
            if (isFront) ...[
              CcIconButton.bouncing(
                onTap: controller.toggleLiabilityCardStack,
                icon: Icon(
                  Icons.swap_vert_rounded,
                  color: scheme.onPrimary.withOpacity(0.6),
                  size: context.respIconSize(baseSize: 20),
                ),
                width: context.respDim(32),
                height: context.respDim(32),
              ),
              const CcSpaceSM(),
            ],
            Container(
              padding: EdgeInsets.all(context.respDim(6)),
              decoration: BoxDecoration(
                color: scheme.onPrimary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: CcIconToken(
                Icons.trending_up,
                color: scheme.onPrimary,
                size: context.respIconSize(baseSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
