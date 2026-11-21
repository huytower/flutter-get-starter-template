import 'package:domain_features/export_domain_features.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

/// The one place that knows which screen controllers hold financial state.
///
/// Each refresh runs only when that controller is mounted (`Get.isRegistered`),
/// so a feature can ask for a refresh without caring which screens are open.
@LazySingleton(as: FinancialRefreshProvider)
class FinancialRefreshProviderImpl implements FinancialRefreshProvider {
  @override
  Future<void> refreshWallets({bool showLoading = true}) async {
    if (Get.isRegistered<WalletController>()) {
      await Get.find<WalletController>().loadWallets(showLoading: showLoading);
    }
  }

  @override
  Future<void> refreshTransactions() async {
    if (Get.isRegistered<TransactionController>()) {
      await Get.find<TransactionController>().refreshData();
    }
  }

  @override
  void addWalletToTransactions(WalletEntity wallet) {
    if (Get.isRegistered<TransactionController>()) {
      Get.find<TransactionController>().wallets.add(wallet);
    }
  }

  @override
  void updateWalletInTransactions(WalletEntity wallet) {
    if (!Get.isRegistered<TransactionController>()) return;
    final transaction = Get.find<TransactionController>();
    final index = transaction.wallets.indexWhere((e) => e.id == wallet.id);
    if (index != -1) {
      transaction.wallets[index] = wallet;
    } else {
      transaction.loadWallets();
    }
  }

  @override
  void removeWalletFromTransactions(String walletId) {
    if (Get.isRegistered<TransactionController>()) {
      Get.find<TransactionController>().wallets.removeWhere(
        (e) => e.id == walletId,
      );
    }
  }

  @override
  Future<void> refreshBudgetAllocation({bool showLoading = true}) async {
    if (Get.isRegistered<BudgetAllocationController>()) {
      await Get.find<BudgetAllocationController>().loadAll(
        showLoading: showLoading,
      );
    }
  }

  @override
  Future<void> refreshBudgetLimits() async {
    if (Get.isRegistered<BudgetLimitController>()) {
      await Get.find<BudgetLimitController>().loadBudgets();
    }
  }

  @override
  Future<void> refreshLiabilityForm() async {
    if (Get.isRegistered<LiabilityFormController>()) {
      await Get.find<LiabilityFormController>().loadLiabilities();
    }
  }

  @override
  Future<void> refreshLiabilityList() async {
    if (Get.isRegistered<LiabilityListController>()) {
      await Get.find<LiabilityListController>().load();
    }
  }

  @override
  Future<void> refreshReport({bool showLoading = true}) async {
    if (Get.isRegistered<ReportController>()) {
      await Get.find<ReportController>().load(showLoading: showLoading);
    }
  }

  @override
  Future<void> refreshReconciliationBalances() async {
    if (Get.isRegistered<ReconciliationController>()) {
      await Get.find<ReconciliationController>().loadBalances();
    }
  }

  @override
  Future<void> refreshCategorySettings() async {
    if (Get.isRegistered<CategorySettingsController>()) {
      await Get.find<CategorySettingsController>().load();
    }
  }

  /// [TransactionController.loadWallets] is a different controller with its
  /// own `RxList` and no loading flag, so it is always refreshed alongside
  /// [TransactionController.refreshWalletTotal].
  @override
  Future<void> refreshAllLoaded() async {
    if (Get.isRegistered<WalletController>()) {
      final walletController = Get.find<WalletController>();
      walletController.markDirty();
      await walletController.loadWallets(
        showLoading: false,
        forceRefresh: true,
      );
    }

    if (Get.isRegistered<TransactionController>()) {
      final transaction = Get.find<TransactionController>();
      await Future.wait([
        transaction.refreshWalletTotal(),
        transaction.loadWallets(),
      ]);
    }

    await refreshBudgetAllocation(showLoading: false);

    if (Get.isRegistered<LendFormController>()) {
      await Get.find<LendFormController>().loadLiabilities();
    }

    await refreshLiabilityForm();
    await refreshLiabilityList();
  }

  /// The GetX controllers are `@lazySingleton` and never disposed, so without
  /// this the previous user's records stay live in their `RxList`s.
  @override
  Future<void> releaseAllLoaded() async {
    try {
      if (Get.isRegistered<WalletController>()) {
        Get.find<WalletController>().wallets.clear();
      }
      if (Get.isRegistered<BudgetAllocationController>()) {
        Get.find<BudgetAllocationController>().liabilityBalances.clear();
      }
      if (Get.isRegistered<LendFormController>()) {
        Get.find<LendFormController>().clearFormOnLogout();
      }
      if (Get.isRegistered<LiabilityFormController>()) {
        Get.find<LiabilityFormController>().clearFormOnLogout();
      }
      if (Get.isRegistered<LiabilityListController>()) {
        Get.find<LiabilityListController>().liabilities.clear();
      }
    } catch (_) {}
  }
}
