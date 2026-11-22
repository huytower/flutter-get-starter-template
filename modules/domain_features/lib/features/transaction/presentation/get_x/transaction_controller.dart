import 'package:app_config/data/datasources/local/box/app_storage/cc_app_storage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/contracts/guideline_provider.dart';
import 'package:domain_features/core/contracts/user_level_provider.dart';
import 'package:domain_features/features/wallet/export_wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/get_x/cc_get_controller.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../../core/quick_entry/quick_entry_intent.dart';
import '../../../liability/presentation/get_x/borrow_form_controller.dart';
import '../../../liability/presentation/get_x/lend_form_controller.dart';
import 'expense_form_controller.dart';
import 'income_form_controller.dart';
import 'investment_form_controller.dart';
import 'tab_change_notifier.dart';
import 'transaction_form_controller.dart';

/// Which real tab a `TabBar`/`TabBarView` slot represents.
enum TransactionTabKind { expense, income, investment, borrow, lend }

@injectable
class TransactionController extends CcGetController {
  TransactionController(
    this._getWalletBalances,
    this._walletRepository,
    this._userLevel,
    this._refresh,
  );

  final FinancialRefreshProvider _refresh;

  final GetWalletBalancesUseCase _getWalletBalances;
  final WalletRepository _walletRepository;
  final UserLevelProvider _userLevel;

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
    TransactionTabKind.borrow,
    TransactionTabKind.lend,
  ];

  /// Returns whether a specific tab is currently unlocked based on user level.
  bool isTabUnlocked(TransactionTabKind kind) {
    if (kind == TransactionTabKind.expense ||
        kind == TransactionTabKind.income) {
      return true;
    }
    if (kind == TransactionTabKind.investment) {
      return _userLevel.status.canUseInvestment;
    }
    if (kind == TransactionTabKind.borrow) {
      return _userLevel.status.canUseLiability;
    }
    if (kind == TransactionTabKind.lend) {
      return _userLevel.status.canUseLiability;
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

  /// Switches to the appropriate tab based on the detected [intent].
  void switchToTabForIntent(QuickEntryIntent intent) {
    switch (intent) {
      case QuickEntryIntent.expense:
        if (isSecondaryCardFront.value) toggleCardStack();
        setTabIndex(0);
        break;
      case QuickEntryIntent.income:
        if (isSecondaryCardFront.value) toggleCardStack();
        setTabIndex(1);
        break;
      case QuickEntryIntent.investment:
        if (!isSecondaryCardFront.value) toggleCardStack();
        setTabIndex(2);
        break;
      case QuickEntryIntent.debt:
        if (!isSecondaryCardFront.value) toggleCardStack();
        setTabIndex(3);
        break;
      case QuickEntryIntent.lend:
        if (!isSecondaryCardFront.value) toggleCardStack();
        setTabIndex(4);
        break;
    }
  }

  /// Returns the controller backing the tab relevant to [intent].
  dynamic getQuickEntryControllerForIntent(QuickEntryIntent intent) =>
      _formControllerFor(_tabForIntent(intent));

  /// Returns the controller backing a specific [tab].
  dynamic getQuickEntryControllerForTab(TransactionTabKind tab) =>
      _formControllerFor(tab);

  static TransactionTabKind _tabForIntent(QuickEntryIntent intent) =>
      switch (intent) {
        QuickEntryIntent.expense => TransactionTabKind.expense,
        QuickEntryIntent.income => TransactionTabKind.income,
        QuickEntryIntent.investment => TransactionTabKind.investment,
        QuickEntryIntent.debt => TransactionTabKind.borrow,
        QuickEntryIntent.lend => TransactionTabKind.lend,
      };

  /// The form controller behind [tab], or null when it is not registered.
  /// With [onlyIfBuilt], also null while it is registered but not built yet:
  /// the controllers are registered lazily so startup stays light, and asking
  /// for one that was never shown would build it just to refresh it.
  TransactionFormController? _formControllerFor(
    TransactionTabKind tab, {
    bool onlyIfBuilt = false,
  }) => switch (tab) {
    TransactionTabKind.expense => _formController<ExpenseFormController>(
      onlyIfBuilt,
    ),
    TransactionTabKind.income => _formController<IncomeFormController>(
      onlyIfBuilt,
    ),
    TransactionTabKind.investment => _formController<InvestmentFormController>(
      onlyIfBuilt,
    ),
    TransactionTabKind.borrow => _formController<BorrowFormController>(
      onlyIfBuilt,
    ),
    TransactionTabKind.lend => _formController<LendFormController>(onlyIfBuilt),
  };

  T? _formController<T extends TransactionFormController>(bool onlyIfBuilt) {
    if (!Get.isRegistered<T>()) return null;
    if (onlyIfBuilt && Get.isPrepared<T>()) return null;
    return Get.find<T>();
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
    ever(CurrencyConstants.onCurrencyChanged, (_) => loadWallets());
    ever(selectedTabIndex, _onTabChanged);

    // Load persisted interaction state
    hasInteractedWithCardStack.value =
        CcAppStorage.instance.hasInteractedWithTransactionCardStack ?? false;

    // Register controllers lazily to avoid heavy waterfall initialization
    // during app startup. They will be created only when their respective
    // form widgets are first built.
    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut(() => getIt<WalletController>());
    }

    if (!Get.isRegistered<ExpenseFormController>()) {
      Get.lazyPut(() => getIt<ExpenseFormController>());
    }
    if (!Get.isRegistered<IncomeFormController>()) {
      Get.lazyPut(() => getIt<IncomeFormController>());
    }
    if (!Get.isRegistered<BorrowFormController>()) {
      Get.lazyPut(() => getIt<BorrowFormController>());
    }
    if (!Get.isRegistered<LendFormController>()) {
      Get.lazyPut(() => getIt<LendFormController>());
    }

    // The transaction tab hosts an always-visible entry form, not a data-gated
    // list, so keep the layout in the success state.
    layoutStatus.value = CcLayoutStatus.success;

    // Defer data fetching slightly to avoid competing with UI transition/boot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshWalletTotal();
      loadWallets();
    });
  }

  /// The tab shown before the latest change.
  int _shownTabIndex = 0;

  TransactionTabKind? _tabAt(int index) {
    final tabs = visibleTabs;
    return index >= 0 && index < tabs.length ? tabs[index] : null;
  }

  /// Lets the form of the tab just left and the one just opened refresh what
  /// went stale (the one place that decides when; see [notifyTabChange]).
  void _onTabChanged(int index) {
    final from = _tabAt(_shownTabIndex);
    _shownTabIndex = index;
    notifyTabChange(
      from: from,
      to: _tabAt(index),
      controllerOf: (tab) => _formControllerFor(tab, onlyIfBuilt: true),
    );
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
          .where((balance) => balance.wallet.type != WalletType.investment)
          .fold<int>(0, (sum, balance) => sum + balance.bookBalance);
    }, (_) {});
  }

  Future<void> refreshData() async {
    await Future.wait([refreshWalletTotal(), loadWallets()]);

    if (Get.isRegistered<WalletController>()) {
      final dynamic wc = Get.find<WalletController>();
      wc.markDirty();
      await wc.loadWallets(forceRefresh: true);
    }

    await _refresh.refreshBudgetAllocation();
  }

  bool get showInvestmentBadge {
    if (!getIt<GuidelineProvider>().isAvailable) return false;
    final guideline = getIt<GuidelineProvider>();
    return guideline.isTaskActive('investment') &&
        guideline.hasCreatedFirstInvestment;
  }

  bool get showLiabilityBadge {
    if (!getIt<GuidelineProvider>().isAvailable) return false;
    final guideline = getIt<GuidelineProvider>();
    return guideline.isTaskActive('liability');
  }

  bool get showLendBadge {
    if (!getIt<GuidelineProvider>().isAvailable) return false;
    final guideline = getIt<GuidelineProvider>();
    return guideline.isTaskActive('lend');
  }

  void openReport(BuildContext context) {
    context.router.push(const ReportRoute());
  }

  void submitCurrentForm(BuildContext context) {
    final tabs = visibleTabs;
    if (selectedTabIndex.value >= tabs.length) return;
    _formControllerFor(tabs[selectedTabIndex.value])?.submitForm(context);
  }
}
