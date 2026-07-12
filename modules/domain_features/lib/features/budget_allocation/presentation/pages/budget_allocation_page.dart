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
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: context.ccColorScheme.primary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: CcText(
        el.tr(CcLocaleKeys.nav_budget_allocation),
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          color: context.ccColorScheme.onPrimary,
          fontWeight: CcTypographyParams.bold,
          letterSpacing: 1.2,
          fontSize: context.respFontSize(16),
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final scheme = sheetContext.ccColorScheme;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(
              sheetContext.respPadding(CcPaddingParams.SPACE_LG),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(sheetContext.respDim(14)),
                    decoration: BoxDecoration(
                      color: scheme.error.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: scheme.error,
                      size: sheetContext.respIconSize(baseSize: 28),
                    ),
                  ),
                ),
                const CcSpaceMD(),
                CcText(
                  el.tr(CcLocaleKeys.wallet_delete_title),
                  align: Alignment.center,
                  textAlign: TextAlign.center,
                  textStyle: sheetContext.ccTextTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const CcSpaceSM(),
                CcText(
                  el.tr(CcLocaleKeys.wallet_delete_confirm_msg),
                  align: Alignment.center,
                  textAlign: TextAlign.center,
                  textStyle: sheetContext.ccTextTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const CcSpaceLG(),
                Row(
                  children: [
                    Expanded(
                      child: CcBaseBtn(
                        title: el.tr(CcLocaleKeys.common_cancel),
                        bgColor: [
                          scheme.surfaceContainerHighest,
                          scheme.surfaceContainerHighest,
                        ],
                        textColor: scheme.onSurface,
                        onTap: () => Navigator.of(sheetContext).pop(),
                      ),
                    ),
                    SizedBox(width: sheetContext.respDim(12)),
                    Expanded(
                      child: CcBaseBtn(
                        title: el.tr(CcLocaleKeys.common_delete),
                        bgColor: [scheme.error, scheme.error],
                        textColor: scheme.onError,
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          final outcome = await controller.walletController
                              .deleteWallet(wallet.id);
                          if (!context.mounted) return;
                          _handleDeleteOutcome(context, outcome);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleDeleteOutcome(BuildContext context, WalletDeleteOutcome outcome) {
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
    final scheme = context.ccColorScheme;
    final walletController = controller.walletController;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_LG),
        context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(context.respDim(24)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.25),
              blurRadius: context.respDim(20),
              offset: Offset(0, context.respDim(10)),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
          vertical: context.respPadding(CcPaddingParams.SPACE_LG),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CcText(
                    el.tr(CcLocaleKeys.wallet_total_assets),
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary.withOpacity(0.85),
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
                        color: scheme.onPrimary,
                        fontWeight: CcTypographyParams.bold,
                        fontSize: context.respFontSize(32),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const CcSpaceLG(),
            Obx(
              () => GestureDetector(
                onTap: walletController.toggleBalanceVisibility,
                child: Container(
                  padding: EdgeInsets.all(context.respDim(12)),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    walletController.isBalanceVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: scheme.primary,
                    size: context.respIconSize(baseSize: 24),
                  ),
                ),
              ),
            ),
          ],
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
