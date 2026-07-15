import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Hero banner displaying total assets with balance visibility toggle.
class BudgetHeroBanner extends StatelessWidget {
  const BudgetHeroBanner({
    required this.walletController,
    super.key,
  });

  final WalletController walletController;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(context.respDim(24)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.25),
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
                    el.tr(CcLocaleKeys.wallet_total_assets),
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary.withOpacity(0.85),
                      fontSize: context.respFontSize(
                        CcTypographyParams.labelMedium,
                      ),
                    ),
                  ),
                  const CcSpaceXS(),
                  Obx(
                    () => CcText(
                      walletController.isBalanceVisible.value
                          ? '${walletController.totalBalance.value.formatShort()} đ'
                          : '*********',
                      textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: CcTypographyParams.bold,
                        fontSize: context.respFontSize(
                          CcTypographyParams.headlineMedium,
                        ),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const CcSpaceLG(),
            Obx(
              () => GestureDetector(
                onTap: walletController.toggleBalanceVisibility,
                child: Container(
                  padding: EdgeInsets.all(context.respDim(12)),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    walletController.isBalanceVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: scheme.primary,
                    size: context.respIconSize(baseSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
