import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../budget_limit/presentation/get_x/budget_limit_controller.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

@injectable
class BudgetAllocationController extends CcGetController {
  BudgetAllocationController(this.walletController, this.budgetLimitController);

  final WalletController walletController;
  final BudgetLimitController budgetLimitController;

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
