import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_limit/presentation/get_x/budget_limit_controller.dart';
import '../../../reconciliation/presentation/get_x/reconciliation_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../widgets/add_wallet_sheet.dart';
import '../widgets/edit_wallet_sheet.dart';
import '../widgets/wallet_delete_confirmation_dialog.dart';

@injectable
class BudgetAllocationController extends CcGetController {
  BudgetAllocationController(this.walletController, this.budgetLimitController);

  final WalletController walletController;
  final BudgetLimitController budgetLimitController;

  void navigateToReconcile(BuildContext context) {
    context.router.push(const ReconcileRoute());
  }

  void openAddWallet(BuildContext context) {
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

  void openWalletActions(BuildContext context, WalletEntity wallet) {
    EditWalletSheet.show(
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
        final outcome = await walletController.deleteWallet(wallet.id);
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
          message: walletController.errorMessage.value.isNotEmpty
              ? walletController.errorMessage.value
              : el.tr(CcLocaleKeys.app_error_general),
        );
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure dependent controllers are registered in GetX for child widgets
    if (!Get.isRegistered<WalletController>()) {
      Get.put(walletController);
    }
    if (!Get.isRegistered<BudgetLimitController>()) {
      Get.put(budgetLimitController);
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadAll();
  }

  Future<void> loadAll() async {
    layoutStatus.value = CcLayoutStatus.loading;

    try {
      // Parallelize loading to satisfy Law 5 (Clean Bootstrap Integrity - parallelize)
      await Future.wait([
        walletController.loadWallets(),
        budgetLimitController.loadBudgets(),
      ]);

      // Aggregate status: if either fails, we could show error
      if (walletController.layoutStatus.value == CcLayoutStatus.error) {
        errorMessage.value = walletController.errorMessage.value;
        layoutStatus.value = CcLayoutStatus.error;
      } else if (budgetLimitController.layoutStatus.value ==
          CcLayoutStatus.error) {
        errorMessage.value = budgetLimitController.errorMessage.value;
        layoutStatus.value = CcLayoutStatus.error;
      } else {
        layoutStatus.value = CcLayoutStatus.success;
      }
    } catch (e) {
      if (kDebugMode) {
        'Error loading budget allocation: $e'.Log();
      }
      errorMessage.value = e.toString();
      layoutStatus.value = CcLayoutStatus.error;
    }
  }
}
