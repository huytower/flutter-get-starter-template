import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../guideline/guideline_controller.dart';
import '../get_x/budget_allocation_controller.dart';
import '../widgets/budget_insights_section.dart';
import '../widgets/budget_limit_preview_section.dart';
import '../widgets/invest_hero_banner.dart';
import '../widgets/investment_wallets_section.dart';
import '../widgets/liability_hero_banner.dart';
import '../widgets/liability_wallets_section.dart';
import '../widgets/liquid_hero_banner.dart';
import '../widgets/liquid_wallets_section.dart';

@RoutePage()
class BudgetAllocationPage extends CcGetView<BudgetAllocationController>
    with CcPullRefreshMixin {
  const BudgetAllocationPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      title: CcText(
        el.tr(CcLocaleKeys.nav_budget_allocation),
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
        ),
      ),
      actions: [
        Obx(
          () => CcIconButton.bouncing(
            onTap: controller.walletController.toggleBalanceVisibility,
            icon: CcIconToken(
              controller.walletController.isBalanceVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
              color: context.ccColorScheme.onPrimary,
            ),
          ),
        ),
        const CcSpaceMD(),
        CcIconButton.bouncing(
          icon: Icon(
            Icons.fact_check_outlined,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          tooltip: el.tr(CcLocaleKeys.reconciliation_title),
          onTap: () => controller.navigateToReconcile(context),
        ),
        SizedBox(width: context.respPadding(CcPaddingParams.SPACE_SM)),
      ],
    );
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
          onRefresh: controller.loadAll,
          child: ListView(
            children: [
              _buildLiquidHeroBanner(context),
              _buildLiquidWalletsSection(context),
              _buildInvestmentHeroBanner(context),
              _buildInvestmentWalletsSection(context),
              _buildLiabilityHeroBanner(context),
              _buildLiabilityWalletsSection(context),
              const BudgetLimitPreviewSection(),
              BudgetInsightsSection(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidHeroBanner(BuildContext context) {
    return LiquidHeroBanner(
      walletController: controller.walletController,
      titleKey: CcLocaleKeys.wallet_liquid_assets,
      balance: controller.walletController.liquidBalance,
      subtitleKey: CcLocaleKeys.wallet_liquid_assets_desc,
      icon: Icons.account_balance_wallet_outlined,
      color: PrjColors.primary,
      bottomPadding: CcPaddingParams.SPACE_XS,
    );
  }

  Widget _buildInvestmentHeroBanner(BuildContext context) {
    return Obx(() {
      final status = controller.userLevel.status.value;
      if (!status.canUseInvestment) {
        return const SizedBox.shrink();
      }

      return InvestHeroBanner(walletController: controller.walletController);
    });
  }

  Widget _buildLiabilityHeroBanner(BuildContext context) {
    return Obx(() {
      final status = controller.userLevel.status.value;
      final canShow = status.canUseDebtLoan;

      if (!canShow) {
        return const SizedBox.shrink();
      }
      return LiabilityHeroBanner(
        walletController: controller.walletController,
        borrowBalance: controller.borrowBalance,
        lendBalance: controller.lendBalance,
        totalBalance: controller.liabilityBalance,
      );
    });
  }

  Widget _buildLiquidWalletsSection(BuildContext context) {
    return Obx(
      () => LiquidWalletsSection(
        wallets: controller.walletController.recentLiquidWallets,
        onAddWallet: () => controller.openAddWallet(context),
        showGuidelineBadge: Get.isRegistered<GuidelineController>()
            ? Get.find<GuidelineController>().isTaskActive('wallet_balance')
            : false,
        badgeColor: Get.isRegistered<GuidelineController>()
            ? Get.find<GuidelineController>().currentColor
            : null,
      ),
    );
  }

  Widget _buildInvestmentWalletsSection(BuildContext context) {
    return Obx(() {
      final status = controller.userLevel.status.value;
      final canShow = status.canUseInvestment;

      if (!canShow) {
        return const SizedBox.shrink();
      }
      final wallets = controller.walletController.recentInvestmentWallets;

      return InvestmentWalletsSection(
        wallets: wallets,
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
      );
    });
  }

  Widget _buildLiabilityWalletsSection(BuildContext context) {
    return Obx(() {
      final status = controller.userLevel.status.value;
      final canShow = status.canUseDebtLoan;

      if (!canShow) {
        return const SizedBox.shrink();
      }

      return LiabilityWalletsSection(
        borrowBalances: controller.borrowBalances,
        lendBalances: controller.lendBalances,
        onAddLoan: () => controller.openAddLiability(context),
        onSeeAll: () => controller.navigateToLiabilityList(context),
        showGuidelineBadge: Get.isRegistered<GuidelineController>()
            ? Get.find<GuidelineController>().isTaskActive('liability') &&
                  !Get.find<GuidelineController>()
                      .hasCreatedFirstLiability
                      .value
            : false,
        badgeColor: Get.isRegistered<GuidelineController>()
            ? Get.find<GuidelineController>().currentColor
            : null,
      );
    });
  }
}
