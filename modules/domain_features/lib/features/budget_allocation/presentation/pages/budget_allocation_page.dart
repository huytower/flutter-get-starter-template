import 'package:auto_route/auto_route.dart';
import 'package:cc_mixin/export_cc_mixin.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../get_x/budget_allocation_controller.dart';
import '../widgets/add_wallet_sheet.dart';
import '../widgets/budget_preview_section.dart';
import '../widgets/wallet_strip.dart';

@RoutePage()
class BudgetAllocationPage extends CcGetView<BudgetAllocationController>
    with CcPullRefreshMixin {
  const BudgetAllocationPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final walletController = controller.walletController;
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.ccColorScheme.primary,
              context.ccColorScheme.primaryContainer,
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.fact_check_outlined,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          tooltip: el.tr(CcLocaleKeys.reconciliation_title),
          onPressed: () => context.router.push(const ReconcileRoute()),
        ),
        SizedBox(width: context.respPadding(CcPaddingParams.SPACE_SM)),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(context.respDim(80)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.SPACE_LG),
            0,
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CcText(
                    el.tr(CcLocaleKeys.wallet_total_assets),
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: context.ccColorScheme.onPrimary.withOpacity(0.8),
                      fontSize: context.respFontSize(14),
                    ),
                  ),
                  const CcSpaceXS(),
                  Obx(
                    () => CcText(
                      walletController.isBalanceVisible.value
                          ? '${walletController.totalBalance.value.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")} đ'
                          : '*********',
                      textStyle: context.ccTextTheme.headlineMedium?.copyWith(
                        color: context.ccColorScheme.onPrimary,
                        fontWeight: CcTypographyParams.bold,
                        fontSize: context.respFontSize(28),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(
                () => GestureDetector(
                  onTap: walletController.toggleBalanceVisibility,
                  child: Container(
                    margin: EdgeInsets.only(bottom: context.respDim(4)),
                    padding: EdgeInsets.all(context.respDim(8)),
                    decoration: BoxDecoration(
                      color: context.ccColorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      walletController.isBalanceVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: context.ccColorScheme.primary,
                      size: context.respIconSize(baseSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: sheetContext.ccColorScheme.primary,
              ),
              title: CcText(el.tr(CcLocaleKeys.common_edit)),
              onTap: () {
                Navigator.pop(sheetContext);
                _editWallet(context, wallet);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: sheetContext.ccColorScheme.error,
              ),
              title: CcText(
                el.tr(CcLocaleKeys.common_delete),
                textStyle: TextStyle(color: sheetContext.ccColorScheme.error),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _confirmDelete(context, wallet);
              },
            ),
          ],
        ),
      ),
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
    CcDialogHelper.showConfirmationDialog(
      desc: el.tr(CcLocaleKeys.wallet_delete_confirm_msg),
      isCancelBtnShown: true,
      onTapConfirm: () async {
        final outcome = await controller.walletController.deleteWallet(
          wallet.id,
        );
        if (!context.mounted) return;
        switch (outcome) {
          case WalletDeleteOutcome.success:
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
          case WalletDeleteOutcome.error:
            CcSnackBarHelper.showErrorSnackBar(
              context: context,
              message: controller.walletController.errorMessage.value.isNotEmpty
                  ? controller.walletController.errorMessage.value
                  : el.tr(CcLocaleKeys.app_error_general),
            );
            break;
        }
      },
    );
  }

  @override
  Widget? buildContent(BuildContext context) {
    return FadePageWrapper(
      child: Builder(
        builder: (context) => buildPullToRefresh(
          context: context,
          onRefresh: controller.loadAll,
          child: ListView(
            children: [
              _buildWalletsSection(context),
              const BudgetPreviewSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletsSection(BuildContext context) {
    final scheme = context.ccColorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_MD),
            context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(CcLocaleKeys.wallet_your_wallets),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onBackground,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openAddWallet(context),
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      size: context.respIconSize(baseSize: 20),
                      color: scheme.primary,
                    ),
                  ),
                  SizedBox(width: context.respDim(8)),
                  GestureDetector(
                    onTap: () => context.router.push(const WalletListRoute()),
                    child: CcText(
                      el.tr(CcLocaleKeys.wallet_see_all),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: CcTypographyParams.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        WalletStrip(
          wallets: controller.walletController.wallets,
          onMore: (wallet) => _openWalletActions(context, wallet),
        ),
      ],
    );
  }
}
