import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/wallet_controller.dart';
import 'add_wallet_sheet.dart';

class WalletHeader extends StatelessWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.ccColorScheme.primary,
            context.ccColorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      padding: EdgeInsets.only(
        left: context.respPadding(CcPaddingParams.SPACE_LG),
        right: context.respPadding(CcPaddingParams.SPACE_LG),
        top: context.respPadding(CcPaddingParams.SPACE_SM),
        bottom: context.respPadding(CcPaddingParams.SPACE_XL),
      ),
      child: Container(
        padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_LG)),
        decoration: BoxDecoration(
          color: context.ccColorScheme.onPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24), // Tăng bo góc cho giống ảnh
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  el.tr(CcLocaleKeys.wallet_total_assets),
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: context.ccColorScheme.onPrimary.withOpacity(0.8),
                    fontSize: context.respFontSize(16),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Row(
                    children: [
                      CcText(
                        controller.isBalanceVisible.value
                            ? '${controller.totalBalance.value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ'
                            : '*********',
                        textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                          color: context.ccColorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: context.respFontSize(32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: controller.toggleBalanceVisibility,
                        child: Icon(
                          controller.isBalanceVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: context.ccColorScheme.onPrimary.withOpacity(
                            0.8,
                          ),
                          size: context.respIconSize(baseSize: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                CcDialogHelper.showModalBottomSheet(
                  context,
                  const AddWalletSheet(),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Mở rộng vùng cảm ứng
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.ccColorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: context.ccColorScheme.primary,
                    size: context.respIconSize(baseSize: 32),
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
