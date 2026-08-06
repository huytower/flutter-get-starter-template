import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_balances_usecase.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'expense_form_controller.dart';
import 'income_form_controller.dart';

@injectable
class TransactionController extends CcGetController {
  TransactionController(
    this._repository,
    this._getWalletBalances,
    this._walletRepository,
  );

  final TransactionRepository _repository;
  final GetWalletBalancesUseCase _getWalletBalances;
  final WalletRepository _walletRepository;

  final RxInt selectedTabIndex = 0.obs;

  /// True when the page header should be auto-hidden (scrolled down, or a
  /// keypad / soft keyboard is visible).
  final RxBool isHeaderHidden = false.obs;

  /// True while the custom transaction keypad (or soft keyboard) is shown.
  final RxBool isKeypadOpen = false.obs;

  /// Total book balance across all wallets, shown in the header "Ví" chip.
  final RxInt walletTotal = 0.obs;

  /// Shared wallet list for all forms to avoid duplicate API calls
  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final RxBool isLoadingWallets = false.obs;

  /// Temporary flag to show wallet summary in the AppBar for 2 seconds.
  final RxBool showWalletSummaryTemporarily = false.obs;

  void setTabIndex(int index) {
    selectedTabIndex.value = index;
    // The newly selected form starts at scroll offset 0, so ensure the header
    // is shown (scroll-driven hiding is handled per-form by each form's
    // TransactionFormController).
    isHeaderHidden.value = false;
  }

  /// Temporarily shows the wallet summary in place of the title for 2 seconds.
  void flashWalletSummary() {
    showWalletSummaryTemporarily.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      showWalletSummaryTemporarily.value = false;
    });
  }

  @override
  void onInit() {
    super.onInit();
    // Register form controllers early to avoid "setState() called during build"
    // errors when they are initialized during the view's build phase.
    if (!Get.isRegistered<ExpenseFormController>()) {
      Get.put(getIt<ExpenseFormController>());
    }
    if (!Get.isRegistered<IncomeFormController>()) {
      Get.put(getIt<IncomeFormController>());
    }

    // The transaction tab hosts an always-visible entry form, not a data-gated
    // list, so keep the layout in the success state.
    layoutStatus.value = CcLayoutStatus.success;
    refreshWalletTotal();
    loadWallets();
  }

  Future<void> loadWallets() async {
    isLoadingWallets.value = true;
    final result = await _walletRepository.getWallets();
    isLoadingWallets.value = false;
    result.when((walletList) => wallets.assignAll(walletList), (_) {});
  }

  Future<void> refreshWalletTotal() async {
    final result = await _getWalletBalances();
    result.when((balances) {
      walletTotal.value = balances.fold<int>(
        0,
        (sum, b) => sum + b.bookBalance,
      );
    }, (_) {});
  }

  Future<void> refreshData() async {
    await refreshWalletTotal();
    if (Get.isRegistered<BudgetAllocationController>()) {
      Get.find<BudgetAllocationController>().loadAll();
    }
  }

  void openReport(BuildContext context) {
    if (Get.isRegistered<ReportController>()) {
      Get.find<ReportController>().load(showLoading: false);
    }
    context.router.push(const ReportRoute());
  }

  void submitCurrentForm(BuildContext context) {
    switch (selectedTabIndex.value) {
      case 0:
        if (Get.isRegistered<ExpenseFormController>()) {
          Get.find<ExpenseFormController>().submitForm(context);
        }
        break;
      case 1:
        if (Get.isRegistered<IncomeFormController>()) {
          Get.find<IncomeFormController>().submitForm(context);
        }
        break;
    }
  }
}
