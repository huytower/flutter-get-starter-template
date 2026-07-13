import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../wallet/presentation/get_x/wallet_controller.dart';

class BudgetAllocationHeader extends StatelessWidget {
  const BudgetAllocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_MD),
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_SM),
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
                    fontSize: context.respFontSize(
                      CcTypographyParams.labelMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => CcText(
                    controller.isBalanceVisible.value
                        ? '${controller.totalBalance.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ'
                        : '*********',
                    textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                      color: context.ccColorScheme.onPrimary,
                      fontWeight: CcTypographyParams.bold,
                      fontSize: context.respFontSize(
                        CcTypographyParams.headlineMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => GestureDetector(
                onTap: controller.toggleBalanceVisibility,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.ccColorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.respDim(6)),
                      child: Icon(
                        controller.isBalanceVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: context.ccColorScheme.primary,
                        size: context.respIconSize(baseSize: 24),
                      ),
                    ),
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
