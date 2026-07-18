import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../../reconciliation/presentation/get_x/reconciliation_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../get_x/budget_allocation_controller.dart';
import '../widgets/add_wallet_sheet.dart';
import '../widgets/budget_hero_banner.dart';
import '../widgets/budget_preview_section.dart';
import '../widgets/budget_wallets_section.dart';
import '../widgets/wallet_actions_bottom_sheet.dart';
import '../widgets/wallet_delete_confirmation_dialog.dart';

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
          onTap: () => context.router.push(const ReconcileRoute()),
        ),
        SizedBox(width: context.respPadding(CcPaddingParams.SPACE_SM)),
      ],
    );
  }

  void _openAddWallet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddWalletSheet(),
    );
  }

  void _openWalletActions(BuildContext context, WalletEntity wallet) {
    WalletActionsBottomSheet.show(
      context,
      wallet: wallet,
      onEdit: () => _editWallet(context, wallet),
      onDelete: () => _confirmDelete(context, wallet),
    );
  }

  void _editWallet(BuildContext context, WalletEntity wallet) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddWalletSheet(wallet: wallet),
    );
  }

  void _confirmDelete(BuildContext context, WalletEntity wallet) {
    WalletDeleteConfirmationDialog.show(
      context,
      wallet: wallet,
      onConfirm: () async {
        final outcome = await controller.walletController.deleteWallet(
          wallet.id,
        );
        if (!context.mounted) return;
        _handleDeleteOutcome(context, outcome);
      },
    );
  }

  void _handleDeleteOutcome(BuildContext context, WalletDeleteOutcome outcome) {
    switch (outcome) {
      case WalletDeleteOutcome.success:
        if (Get.isRegistered<ReconciliationController>()) {
          Get.find<ReconciliationController>().loadBalances();
        }
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.common_done),
        );
        break;
      case WalletDeleteOutcome.notEmpty:
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.wallet_delete_error_not_empty),
        );
        break;
      case WalletDeleteOutcome.protected:
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.wallet_delete_error_protected),
        );
        break;
      case WalletDeleteOutcome.error:
        CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: controller.walletController.errorMessage.value.isNotEmpty
              ? controller.walletController.errorMessage.value
              : el.tr(CcLocaleKeys.app_error_general),
        );
        break;
    }
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
      onAddWallet: () => _openAddWallet(context),
      onMore: (wallet) => _openWalletActions(context, wallet),
    );
  }
}
