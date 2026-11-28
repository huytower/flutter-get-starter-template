import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:message/export_message.dart';

import '../widgets/add_liquid_sheet.dart';
import '../widgets/investment_delete_sheet.dart';
import 'wallet_controller.dart';

/// The add/edit and delete sheets of the wallet list screens.
extension WalletSheets on WalletController {
  /// Leaves edit mode, or closes the screen when not editing.
  void onCloseEditMode(BuildContext context) {
    if (hasEditMode.value) {
      hasEditMode.value = false;
    } else {
      Navigator.of(context).pop();
    }
  }

  void openForm(BuildContext context, {WalletEntity? wallet}) {
    CcAdaptiveBottomSheet.show<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddLiquidSheet(wallet: wallet),
    );
  }

  /// Deletes an untouched investment wallet at once; otherwise asks first.
  Future<void> confirmDelete(BuildContext context, WalletEntity wallet) async {
    final hasInvestment = wallet.type == WalletType.investment;
    if (hasInvestment) {
      final stats = investmentStatsOf(wallet.id);
      if (stats.contributed == 0 && stats.returned == 0) {
        _showOutcome(null, await deleteWallet(wallet.id));
        return;
      }
    }

    final confirmed = hasInvestment
        ? await InvestmentDeleteSheet.show(context)
        : await CcConfirmSheet.show(
            context,
            icon: Icons.delete_outline_rounded,
            title: el.tr(PrjLocaleKeys.wallet_delete_title),
            message: el.tr(PrjLocaleKeys.wallet_delete_confirm_msg),
            confirmLabel: el.tr(PrjLocaleKeys.common_delete),
          );
    if (!confirmed) return;
    final outcome = await deleteWallet(wallet.id);
    if (!context.mounted) return;
    _showOutcome(context, outcome);
  }

  void _showOutcome(BuildContext? context, WalletDeleteOutcome outcome) {
    final activeContext = (context != null && context.mounted)
        ? context
        : Get.context;
    if (activeContext == null) return;

    switch (outcome) {
      case WalletDeleteOutcome.success:
        effects.deletionConfirmed();
        CcSnackBarHelper.showSuccessSnackBar(
          context: activeContext,
          message: el.tr(PrjLocaleKeys.common_done),
        );
      case WalletDeleteOutcome.notEmpty:
        CcSnackBarHelper.showErrorSnackBar(
          context: activeContext,
          message: el.tr(PrjLocaleKeys.wallet_delete_error_not_empty),
        );
      case WalletDeleteOutcome.protected:
        CcSnackBarHelper.showErrorSnackBar(
          context: activeContext,
          message: el.tr(PrjLocaleKeys.wallet_delete_error_protected),
        );
      case WalletDeleteOutcome.error:
        CcSnackBarHelper.showErrorSnackBar(
          context: activeContext,
          message: errorMessage.value.isNotEmpty
              ? errorMessage.value
              : el.tr(PrjLocaleKeys.app_error_general),
        );
    }
  }
}
