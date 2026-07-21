import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
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
              _buildHeroBanner(context),
              _buildWalletsSection(context),
              const BudgetPreviewSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return BudgetHeroBanner(walletController: controller.walletController);
  }

  Widget _buildWalletsSection(BuildContext context) {
    return BudgetWalletsSection(
      wallets: controller.walletController.wallets,
      onAddWallet: () => controller.openAddWallet(context),
      onMore: (wallet) => controller.openWalletActions(context, wallet),
    );
  }
}
