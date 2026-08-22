import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../liability/presentation/get_x/lend_form_controller.dart';
import '../../../liability/presentation/get_x/liability_form_controller.dart';
import '../../../report/presentation/get_x/report_controller.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_balances_usecase.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'expense_form_controller.dart';
import 'income_form_controller.dart';
import 'investment_form_controller.dart';

/// Which real tab a `TabBar`/`TabBarView` slot represents.
enum TransactionTabKind { expense, income, investment, liability, lend }

@injectable
class TransactionController extends CcGetController {
  TransactionController(
    this._repository,
    this._getWalletBalances,
    this._walletRepository,
    this._userLevel,
  );

  final TransactionRepository _repository;
  final GetWalletBalancesUseCase _getWalletBalances;
  final WalletRepository _walletRepository;
  final UserLevelController _userLevel;

  final RxInt selectedTabIndex = 0.obs;

  /// Whether the secondary card (Investment | Liability | Lend) is currently in front.
  final RxBool isSecondaryCardFront = false.obs;

  /// Whether the user has interacted with the card stack at least once.
  /// Persisted in [CcAppStorage] to hide the interaction hint.
  final RxBool hasInteractedWithCardStack = false.obs;

  /// Tabs currently visible, in display order.
  ///
  /// Front card: [expense, income]
  /// Back card: [investment, liability, lend]
  List<TransactionTabKind> get visibleTabs => [
    TransactionTabKind.expense,
    TransactionTabKind.income,
    TransactionTabKind.investment,
    TransactionTabKind.liability,
    TransactionTabKind.lend,
  ];

  /// Returns whether a specific tab is currently unlocked based on user level.
  bool isTabUnlocked(TransactionTabKind kind) {
    if (kind == TransactionTabKind.expense ||
        kind == TransactionTabKind.income) {
      return true;
    }
    if (kind == TransactionTabKind.investment) {
      return _userLevel.status.value.canUseInvestment;
    }
    if (kind == TransactionTabKind.liability) {
      return _userLevel.status.value.canUseDebtLoan;
    }
    return false;
  }

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
    isHeaderHidden.value = false;
  }

  /// Temporarily shows the wallet summary in place of the title for 2 seconds.
  void flashWalletSummary() {
    showWalletSummaryTemporarily.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      showWalletSummaryTemporarily.value = false;
    });
  }

  /// Swaps the front/back cards in the transaction tab stack.
  void toggleCardStack() {
    isSecondaryCardFront.value = !isSecondaryCardFront.value;
    markStackInteracted();

    // When swapping to a card, automatically select its first tab if the
    // current selection is on the other card.
    final currentIndex = selectedTabIndex.value;
    if (isSecondaryCardFront.value) {
      if (currentIndex < 2) setTabIndex(2);
    } else {
      if (currentIndex >= 2) setTabIndex(0);
    }
  }

  /// Marks that the user has interacted with the card stack.
  void markStackInteracted() {
    if (!hasInteractedWithCardStack.value) {
      hasInteractedWithCardStack.value = true;
      CcAppStorage.instance.hasInteractedWithTransactionCardStack = true;
      CcAppStorage.instance.save();
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Load persisted interaction state
    hasInteractedWithCardStack.value =
        CcAppStorage.instance.hasInteractedWithTransactionCardStack ?? false;

    // Ensure WalletController is available for book balance lookups in selectors
    if (!Get.isRegistered<WalletController>()) {
      Get.put(getIt<WalletController>());
    }

    // Register form controllers early to avoid "setState() called during build"
    // errors when they are initialized during the view's build phase.
    //
    // Investment/Loan are deliberately NOT eagerly registered here too
    // (unlike Expense/Income) — InvestmentFormController.onInit() calls
    // Get.find<TransactionController>(), and calling that synchronously
    // from inside THIS method (TransactionController's own onInit(), still
    // mid-execution) would re-enter this exact onInit() body recursively:
    // GetInstance only marks a controller's `isInit` flag true *after*
    // onStart()/onInit() fully returns, so a nested Get.find() that lands
    // here before this call finishes sees `isInit == false` and restarts
    // onStart()/onInit() a second time (verified against the `get` 4.7.3
    // package source — GetLifeCycleBase._onStart()'s own `_initialized`
    // guard doesn't help either, since it's likewise only flipped after
    // onInit() returns). See TransactionPage.buildContent(), which runs
    // strictly after this onInit() has fully completed, for where
    // Investment/Loan actually get pre-registered instead.
    if (!Get.isRegistered<ExpenseFormController>()) {
      Get.put(getIt<ExpenseFormController>());
    }
    if (!Get.isRegistered<IncomeFormController>()) {
      Get.put(getIt<IncomeFormController>());
    }
    if (!Get.isRegistered<LiabilityFormController>()) {
      Get.put(getIt<LiabilityFormController>());
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
      // Investment positions aren't spendable cash, so they're excluded from
      // the "Ví" total shown in the header — matches [_liquidOnly] in
      // TransactionFormController.
      walletTotal.value = balances
          .where((b) => b.wallet.type != WalletType.investment)
          .fold<int>(0, (sum, b) => sum + b.bookBalance);
    }, (_) {});
  }

  Future<void> refreshData() async {
    await refreshWalletTotal();
    await loadWallets();

    if (Get.isRegistered<WalletController>()) {
      Get.find<WalletController>().loadWallets();
    }

    if (Get.isRegistered<BudgetAllocationController>()) {
      Get.find<BudgetAllocationController>().loadAll();
    }
  }

  bool get showInvestmentBadge {
    if (!Get.isRegistered<GuidelineController>()) return false;
    final guideline = Get.find<GuidelineController>();
    return guideline.isTaskActive('investment') &&
        guideline.hasCreatedFirstInvestment.value;
  }

  bool get showLiabilityBadge {
    if (!Get.isRegistered<GuidelineController>()) return false;
    final guideline = Get.find<GuidelineController>();
    return guideline.isTaskActive('liability') &&
        guideline.hasCreatedFirstLiability.value;
  }

  void openReport(BuildContext context) {
    if (Get.isRegistered<ReportController>()) {
      Get.find<ReportController>().load(showLoading: false);
    }
    context.router.push(const ReportRoute());
  }

  void submitCurrentForm(BuildContext context) {
    final tabs = visibleTabs;
    if (selectedTabIndex.value >= tabs.length) return;
    switch (tabs[selectedTabIndex.value]) {
      case TransactionTabKind.expense:
        if (Get.isRegistered<ExpenseFormController>()) {
          Get.find<ExpenseFormController>().submitForm(context);
        }
        break;
      case TransactionTabKind.income:
        if (Get.isRegistered<IncomeFormController>()) {
          Get.find<IncomeFormController>().submitForm(context);
        }
        break;
      case TransactionTabKind.investment:
        if (Get.isRegistered<InvestmentFormController>()) {
          Get.find<InvestmentFormController>().submitForm(context);
        }
        break;
      case TransactionTabKind.liability:
        if (Get.isRegistered<LiabilityFormController>()) {
          Get.find<LiabilityFormController>().submitForm(context);
        }
        break;
      case TransactionTabKind.lend:
        if (Get.isRegistered<LendFormController>()) {
          Get.find<LendFormController>().submitForm(context);
        }
        break;
    }
  }
}
