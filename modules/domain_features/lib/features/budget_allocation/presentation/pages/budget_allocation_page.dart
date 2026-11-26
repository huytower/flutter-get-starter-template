import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/di/di.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/get_x/prj_get_view.dart';
import '../../../liability/export_liability.dart';
import '../../../reconciliation/presentation/actions/reconciliation_entry_guard.dart';
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
class BudgetAllocationPage extends PrjGetView<BudgetAllocationController>
    with CcPullToRefreshMixin {
  const BudgetAllocationPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildBudgetAllocationHeader(
      context,
      onReconcile: () => getIt<ReconciliationEntryGuard>().open(context),
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return CcFadePageWrapper(
      // The list scrolls across the full width; its content is centred and
      // capped at the content width on wide windows.
      child: LayoutBuilder(
        builder: (context, constraints) => buildPullToRefresh(
          context: context,
          onRefresh: controller.refreshFromCloud,
          child: ListView(
            padding: EdgeInsets.symmetric(
              vertical: context.respPadding(CcPaddingParams.SPACE_MD),
              // Two-column mode centres and caps itself (CcTwoColumn).
              horizontal: CcTwoColumn.shouldUse(context)
                  ? 0
                  : CcMaxWidth.insetFor(constraints.maxWidth),
            ),
            children: CcTwoColumn.shouldUse(context)
                ? [
                    // Landscape tablet: cash and investments on the left,
                    // debts, budget limits and insights on the right. The
                    // sections carry their own horizontal padding, so no gap.
                    CcTwoColumn(
                      gap: 0,
                      left: [
                        _buildLiquidGroup(context),
                        _buildInvestmentGroup(context),
                      ],
                      right: [
                        _buildLiabilityGroup(context),
                        _buildBudgetLimitGroup(context),
                        _buildInsightsGroup(context),
                      ],
                    ),
                  ]
                : [
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
      final status = controller.userLevel.status;
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
            showGuidelineBadge: getIt<GuidelineProvider>().hasAvailable
                ? getIt<GuidelineProvider>().hasTaskActive('investment') &&
                      !getIt<GuidelineProvider>().hasCreatedFirstInvestment
                : false,
            badgeColor: getIt<GuidelineProvider>().hasAvailable
                ? getIt<GuidelineProvider>().currentColor
                : null,
          ),
          const CcSpaceXL(),
        ],
      );
    });
  }

  Widget _buildLiabilityGroup(BuildContext context) {
    return Obx(() {
      final status = controller.userLevel.status;
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
            onAddLiability: () => controller.openAddLiability(
              context,
              initialDirection: controller.hasLendSectionFront.value
                  ? LiabilityDirection.lend
                  : LiabilityDirection.borrow,
            ),
            onSeeAll: () => controller.navigateToLiabilityList(context),
            hasLendFront: controller.hasLendSectionFront.value,
            showGuidelineBadge: getIt<GuidelineProvider>().hasAvailable
                ? getIt<GuidelineProvider>().hasTaskActive('liability') &&
                      !getIt<GuidelineProvider>().hasCreatedFirstLiability
                : false,
            badgeColor: getIt<GuidelineProvider>().hasAvailable
                ? getIt<GuidelineProvider>().currentColor
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
      titleKey: PrjLocaleKeys.wallet_liquid_assets,
      balance: controller.walletController.liquidBalance,
      subtitleKey: PrjLocaleKeys.wallet_liquid_assets_desc,
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
        showGuidelineBadge: getIt<GuidelineProvider>().hasAvailable
            ? getIt<GuidelineProvider>().hasTaskActive('wallet_balance')
            : false,
        badgeColor: getIt<GuidelineProvider>().hasAvailable
            ? getIt<GuidelineProvider>().currentColor
            : null,
      );
    });
  }
}
