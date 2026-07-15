import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/getx/cc_get_view.dart';
import '../../../../core/util/gradient_app_bar.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';
import '../widgets/add_wallet_sheet.dart';
import '../widgets/wallet_delete_confirm_sheet.dart';
import '../widgets/wallet_list_card.dart';

@RoutePage()
class WalletListPage extends CcGetView<WalletController> {
  const WalletListPage({super.key});

  @override
  bool get enableAppBar => true;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return buildDomainGradientAppBar(
      context,
      leading: CcIconButton.bouncing(
        icon: Icon(
          controller.isEditMode.value
              ? Icons.close_rounded
              : Icons.arrow_back_ios_new_rounded,
          color: context.ccColorScheme.onPrimary,
          size: context.respIconSize(baseSize: 24),
        ),
        onTap: () {
          controller.isEditMode.value = false;
          Navigator.of(context).pop();
        },
      ),
      title: Center(
        child: CcText(
          el.tr(CcLocaleKeys.wallet_your_wallets),
          textStyle: context.ccTextTheme.titleMedium?.copyWith(
            color: context.ccColorScheme.onPrimary,
            fontWeight: CcTypographyParams.bold,
            fontSize: context.respFontSize(CcTypographyParams.titleMedium),
          ),
        ),
      ),
      actions: [
        CcIconButton.bouncing(
          icon: Icon(
            Icons.add,
            color: context.ccColorScheme.onPrimary,
            size: context.respIconSize(baseSize: 24),
          ),
          tooltip: el.tr(CcLocaleKeys.wallet_add_title),
          onTap: () => _openForm(context),
        ),
        Obx(
          () => CcIconButton.bouncing(
            onTap: controller.toggleEditMode,
            tooltip: controller.isEditMode.value
                ? el.tr(CcLocaleKeys.common_done)
                : el.tr(CcLocaleKeys.common_edit),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                controller.isEditMode.value
                    ? Icons.check_circle_outline_rounded
                    : Icons.tune_rounded,
                key: ValueKey(controller.isEditMode.value),
                color: context.ccColorScheme.onPrimary,
                size: context.respIconSize(baseSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openForm(BuildContext context, {WalletEntity? wallet}) {
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
      builder: (_) => WalletDeleteConfirmSheet(
        wallet: wallet,
        onDelete: () => controller.deleteWallet(wallet.id),
        onOutcome: (outcome) => _handleDeleteOutcome(context, outcome),
      ),
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
          message: controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : el.tr(CcLocaleKeys.app_error_general),
        );
        break;
    }
  }

  @override
  Widget? buildContent(BuildContext context) {
    return Builder(
      builder: (context) => Obx(() {
        if (controller.wallets.isEmpty) {
          return Center(
            child: CcText(
              el.tr(CcLocaleKeys.wallet_empty),
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.bodyLarge?.copyWith(
                color: context.ccColorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final isEdit = controller.isEditMode.value;
        return ListView(
          padding: EdgeInsets.all(
            context.respPadding(CcPaddingParams.SPACE_MD),
          ),
          children: controller.wallets
              .map(
                (wallet) => WalletListCard(
                  wallet: wallet,
                  isEditMode: isEdit,
                  canDelete: controller.canDeleteWallet(wallet),
                  onEdit: () => _openForm(context, wallet: wallet),
                  onDelete: () => _confirmDelete(context, wallet),
                ),
              )
              .toList(),
        );
      }),
    );
  }
}
