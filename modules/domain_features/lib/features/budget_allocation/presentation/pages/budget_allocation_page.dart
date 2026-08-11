import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../firestore/presentation/widgets/sync_status_icon.dart';
import '../get_x/budget_allocation_controller.dart';
import '../widgets/budget_hero_banner.dart';
import '../widgets/budget_preview_section.dart';
import '../widgets/budget_wallets_section.dart';

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
          () => CcInkWell(
            onTap: controller.walletController.toggleBalanceVisibility,
            child: Container(
              padding: EdgeInsets.all(context.respDim(4)),
              decoration: BoxDecoration(
                color: context.ccColorScheme.onPrimary,
                shape: BoxShape.circle,
              ),
              child: CcIconToken(
                controller.walletController.isBalanceVisible.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 16,
              ),
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
        const CcSpaceXS(),
        const SyncStatusIcon(),
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
              _buildBudgetWalletsSection(context),
              _buildInvestmentHeroBanner(context),
              _buildLiabilityHeroBanner(context),
              const BudgetPreviewSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidHeroBanner(BuildContext context) {
    return BudgetHeroBanner(
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
      if (!controller.userLevel.status.value.canUseInvestment) {
        return const SizedBox.shrink();
      }
      final roi = controller.walletController.investmentRoiPercent.value;
      return BudgetHeroBanner(
        walletController: controller.walletController,
        titleKey: CcLocaleKeys.wallet_investments,
        balance: controller.walletController.investmentBalance,
        subtitleKey: CcLocaleKeys.wallet_investments_desc,
        subtitleArgs: {'roi': roi.toStringAsFixed(1)},
        icon: Icons.trending_up_outlined,
        color: CcBaseColors.yellow600,
        topPadding: CcPaddingParams.SPACE_SM,
        bottomPadding: CcPaddingParams.SPACE_XS,
      );
    });
  }

  Widget _buildLiabilityHeroBanner(BuildContext context) {
    return Obx(() {
      if (!controller.userLevel.status.value.canUseDebtLoan) {
        return const SizedBox.shrink();
      }
      return BudgetHeroBanner(
        walletController: controller.walletController,
        titleKey: CcLocaleKeys.wallet_liabilities,
        balance: controller.liabilityBalance,
        subtitleKey: CcLocaleKeys.wallet_liabilities_desc,
        icon: Icons.report_problem_outlined,
        color: CcBaseColors.violet600,
        topPadding: CcPaddingParams.SPACE_SM,
      );
    });
  }

  Widget _buildBudgetWalletsSection(BuildContext context) {
    return Obx(
      () => BudgetWalletsSection(
        wallets: controller.walletController.liquidWallets,
        onAddWallet: () => controller.openAddWallet(context),
        onMore: (wallet) => controller.openWalletActions(context, wallet),
      ),
    );
  }
}
