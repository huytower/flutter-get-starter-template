import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_limit/domain/entities/budget_insights_entity.dart';
import '../../../budget_limit/domain/usecases/get_budget_insights_usecase.dart';
import '../../../budget_limit/presentation/get_x/budget_limit_controller.dart';
import '../../../loan/domain/entities/loan_balance_entity.dart';
import '../../../loan/domain/usecases/get_loan_balances_usecase.dart';
import '../../../reconciliation/presentation/get_x/reconciliation_controller.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../../wallet/presentation/widgets/add_investment_sheet.dart';
import '../../../wallet/presentation/widgets/add_wallet_sheet.dart';
import '../widgets/edit_wallet_sheet.dart';
import '../widgets/wallet_delete_confirmation_dialog.dart';

@injectable
class BudgetAllocationController extends CcGetController {
  BudgetAllocationController(
    this.walletController,
    this.budgetLimitController,
    this._getLoanBalances,
    this.userLevel,
    this._getBudgetInsights,
  );

  final WalletController walletController;
  final BudgetLimitController budgetLimitController;
  final GetLoanBalancesUseCase _getLoanBalances;
  final UserLevelController userLevel;
  final GetBudgetInsightsUseCase _getBudgetInsights;

  final RxInt liabilityBalance = 0.obs;
  final RxList<LoanBalanceEntity> loanBalances = <LoanBalanceEntity>[].obs;

  /// Phase 3.4 "AI Actions" — null while loading/on error, in which case the
  /// insights panel simply doesn't render (see [BudgetInsightsEntity.hasAnything]).
  final Rx<BudgetInsightsEntity?> insights = Rx<BudgetInsightsEntity?>(null);

  void navigateToReconcile(BuildContext context) {
    context.router.push(const ReconcileRoute());
  }

  void navigateToInvestmentList(BuildContext context) {
    context.router.push(const InvestmentListRoute());
  }

  void navigateToLoanList(BuildContext context) {
    context.router.push(const LoanListRoute());
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

  void openAddInvestment(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddInvestmentSheet(),
    );
  }

  void openWalletActions(BuildContext context, WalletEntity wallet) {
    EditWalletSheet.show(
      context,
      wallet: wallet,
      onEdit: () => wallet.type == WalletType.investment
          ? _editInvestment(context, wallet)
          : _editWallet(context, wallet),
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

  void _editInvestment(BuildContext context, WalletEntity wallet) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddInvestmentSheet(wallet: wallet),
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
        loadLiabilities(),
        userLevel.refresh(),
        loadInsights(),
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

  /// Phase 3.4 budget insights (pacing/penalty/deficit/anomaly warnings) for
  /// the allocation page's insights panel. Failures are swallowed like
  /// [loadLiabilities] — an insights fetch error shouldn't blank out the
  /// wallets/budgets sections too.
  Future<void> loadInsights() async {
    final result = await _getBudgetInsights.call();
    result.when((success) => insights.value = success, (_) {});
  }

  /// Sums outstanding borrow-direction loans for the "Nợ phải trả" banner.
  /// Failures are swallowed rather than folded into [layoutStatus] — a loan
  /// fetch error shouldn't blank out the wallets/budgets sections too.
  Future<void> loadLiabilities() async {
    final result = await _getLoanBalances();
    result.when((balances) {
      final sorted = List<LoanBalanceEntity>.from(balances)
        ..sort((a, b) => b.loan.updatedAt.compareTo(a.loan.updatedAt));
      loanBalances.assignAll(sorted);
      liabilityBalance.value = balances
          .where((b) => b.loan.isBorrow && b.status == LoanStatus.outstanding)
          .fold(0, (sum, b) => sum + b.outstandingBalance);
    }, (_) {});
  }
}
