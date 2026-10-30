import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/core/config/tokens/cc_padding_params.dart';
import 'package:cc_sdk_ui/core/extensions/cc_context_extension.dart';
import 'package:cc_sdk_ui/core/extensions/common/cc_responsive_extension.dart';
import 'package:cc_sdk_ui/widgets/anim/fade_page_wrapper.dart';
import 'package:cc_sdk_ui/widgets/space/cc_space.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../guideline/export_guideline.dart';
import '../get_x/budget_allocation_controller.dart';
import '../widgets/budget_allocation_header.dart';
import '../widgets/budget_insights_section.dart';
import '../widgets/budget_limit_preview_section.dart';
import '../widgets/invest_hero_banner.dart';
import '../widgets/investment_wallets_section.dart';
import '../widgets/liability_hero_banner.dart';
import '../widgets/liability_wallets_section.dart';
import '../widgets/liquid_hero_banner.dart';
import '../widgets/liquid_wallets_section.dart';

@RoutePage()
class  BudgetAllocationPage extends CcGetView<BudgetAllocationController>
    with CcPullRefreshMixin {
  const BudgetAllocationPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildBudgetAllocationHeader(context);
  }

  @override
  Widget onPageBodyWrapper(BuildContext context, Widget body) =>
      ColoredBox(color: context.ccColorScheme.background, child: body);

  @override
  Widget? buildContent(BuildContext context) {
    return FadePageWrapper(
      child: Builder(
        builder: (context) => buildPullToRefresh(
          context: context,
          onRefresh: controller.refreshFromCloud,
          child: ListView(
            padding: EdgeInsets.symmetric(
              vertical: context.respPadding(CcPaddingParams.SPACE_MD),
            ),
            children: [
              _buildLiquidGroup(context),
              _buildInvestmentGroup(context),
              _buildLiabilityGroup(context),
              _buildBudgetLimitGroup(context),
              _buildInsightsGroup(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidGroup(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLiquidHeroBanner(context),
        const CcSpaceSM(),
        _buildLiquidWalletsSection(context),
        const CcSpaceLG(),
      ],
    );
  }

  Widget _buildInvestmentGroup(BuildContext context) {
    return Obx(() {
      final status = controller.userLevel.status.value;
      if (!status.canUseInvestment) return const SizedBox.shrink();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InvestHeroBanner(walletController: controller.walletController),
          const CcSpaceSM(),
          InvestmentWalletsSection(
            wallets: controller.walletController.recentInvestmentWallets,
            onAddInvestment: () => controller.openAddInvestment(context),
            onSeeAll: () => controller.navigateToInvestmentList(context),
            showGuidelineBadge: Get.isRegistered<GuidelineController>()
                ? Get.find<GuidelineController>().isTaskActive('investment') &&
                      !Get.find<GuidelineController>()
                          .hasCreatedFirstInvestment
                          .value
                : false,
            badgeColor: Get.isRegistered<GuidelineController>()
                ? Get.find<GuidelineController>().currentColor
                : null,
          ),
          const CcSpaceXL(),
        ],
      );
    });
  }

  Widget _buildLiabilityGroup(BuildContext context) {
    return Obx(() {
      final status = controller.userLevel.status.value;
      if (!status.canUseLiability) return const SizedBox.shrink();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiabilityHeroBanner(
            walletController: controller.walletController,
            borrowBalance: controller.borrowBalance,
            lendBalance: controller.lendBalance,
            totalBalance: controller.liabilityBalance,
          ),
          const CcSpaceXL(),
          LiabilityWalletsSection(
            borrowBalances: controller.borrowBalances,
            lendBalances: controller.lendBalances,
            onAddLiability: () => controller.openAddLiability(context),
            onSeeAll: () => controller.navigateToLiabilityList(context),
            isLendFront: controller.isLendSectionFront.value,
            showGuidelineBadge: Get.isRegistered<GuidelineController>()
                ? Get.find<GuidelineController>().isTaskActive('liability') &&
                      !Get.find<GuidelineController>()
                          .hasCreatedFirstLiability
                          .value
                : false,
            badgeColor: Get.isRegistered<GuidelineController>()
                ? Get.find<GuidelineController>().currentColor
                : null,
          ),
          const CcSpaceLG(),
        ],
      );
    });
  }

  Widget _buildBudgetLimitGroup(BuildContext context) {
    return const BudgetLimitPreviewSection();
  }

  Widget _buildInsightsGroup(BuildContext context) {
    return Obx(() {
      final insights = controller.insights.value;
      if (insights == null || !insights.hasAnything)
        return const SizedBox.shrink();

      return BudgetInsightsSection(controller: controller);
    });
  }

  Widget _buildLiquidHeroBanner(BuildContext context) {
    return LiquidHeroBanner(
      walletController: controller.walletController,
      titleKey: CcLocaleKeys.wallet_liquid_assets,
      balance: controller.walletController.liquidBalance,
      subtitleKey: CcLocaleKeys.wallet_liquid_assets_desc,
      icon: Icons.account_balance_wallet_outlined,
      color: PrjColors.primary,
    );
  }

  Widget _buildLiquidWalletsSection(BuildContext context) {
    return Obx(() {
      final walletCount = controller.walletController.wallets.length;
      final totalBal = controller.walletController.totalBalance.value;
      assert(walletCount >= 0 && totalBal >= 0);
      return LiquidWalletsSection(
        wallets: controller.walletController.recentLiquidWallets,
        onAddWallet: () => controller.openAddWallet(context),
        showGuidelineBadge: Get.isRegistered<GuidelineController>()
            ? Get.find<GuidelineController>().isTaskActive('wallet_balance')
            : false,
        badgeColor: Get.isRegistered<GuidelineController>()
            ? Get.find<GuidelineController>().currentColor
            : null,
      );
    });
  }
}
