import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_flutter_template/presentation/getx_state_management/wallet/get_x/wallet_controller.dart';

class WalletHeader extends StatelessWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return SliverAppBar(
      expandedHeight: context.respDim(200),
      pinned: true,
      stretch: true,
      backgroundColor: context.ccColorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.ccColorScheme.primary,
                context.ccColorScheme.primary.withBlue(255).withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(
                    context.respPadding(CcPaddingParams.SPACE_MD),
                  ),
                  child: CcText(
                    el.tr(CcLocaleKeys.home_my_wallets),
                    textStyle: context.ccTextTheme.titleLarge?.copyWith(
                      color: context.ccColorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: context.respFontSize(20),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.9),
                    itemCount: 1, // Supporting multiple cards with snap
                    itemBuilder: (context, index) {
                      return _buildSummaryCard(context, controller);
                    },
                  ),
                ),
                const CcSpaceMD(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, WalletController controller) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_XS),
      ),
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: context.ccColorScheme.onPrimary.withOpacity(0.15),
        borderRadius: CcWidgetHelper.getBorderRoundedLG(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CcText(
                el.tr(CcLocaleKeys.home_title),
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: context.ccColorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
              const CcSpaceXS(),
              Obx(
                () => Row(
                  children: [
                    CcText(
                      controller.isBalanceVisible.value
                          ? '1.659.699 đ'
                          : '*********',
                      textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                        color: context.ccColorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: context.respFontSize(28),
                      ),
                    ),
                    const CcSpaceSM(),
                    CcInkWell(
                      onTap: controller.toggleBalanceVisibility,
                      child: Icon(
                        controller.isBalanceVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: context.ccColorScheme.onPrimary.withOpacity(0.8),
                        size: context.respIconSize(baseSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(
              context.respPadding(CcPaddingParams.SPACE_XS),
            ),
            decoration: BoxDecoration(
              color: context.ccColorScheme.onPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: context.ccColorScheme.primary,
              size: context.respIconSize(baseSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
