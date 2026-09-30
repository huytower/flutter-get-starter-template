import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/money_format_helper.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

class BudgetAllocationHeader extends StatelessWidget {
  const BudgetAllocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        vertical: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.ccColorScheme.primary,
              context.ccColorScheme.primaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  el.tr(CcLocaleKeys.wallet_total_assets),
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: context.ccColorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
                const CcSpaceMD(),
                Obx(
                  () => CcText(
                    controller.isBalanceVisible.value
                        ? MoneyFormatter.formatWithSymbol(
                            controller.totalBalance.value,
                            currencyCode: controller.currencyCode.value,
                          )
                        : '*********',
                    textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                      color: context.ccColorScheme.onPrimary,
                      fontWeight: CcTypographyParams.bold,
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => CcBouncing(
                onTap: controller.toggleBalanceVisibility,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    controller.isBalanceVisible.value
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: context.ccColorScheme.onPrimary.withOpacity(0.9),
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
