import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/getx/cc_get_controller.dart';
import 'package:domain_features/features/wallet/domain/entities/wallet_totals.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/services/emergency_fund_access.dart';
import 'package:domain_features/features/wallet/domain/services/wallet_ledger.dart';
import 'package:domain_features/features/wallet/domain/usecases/load_wallet_overview_usecase.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:message/export_message.dart';

import '../helper/wallet_ordering.dart';
import 'wallet_change_effects.dart';

/// Outcome of a wallet deletion attempt (rule: only empty wallets deletable).
enum WalletDeleteOutcome { success, notEmpty, protected, error }

/// State of the wallet screens: the wallet list, each wallet's book and
/// display balance, investment stats and the header totals.
///
/// Data work is delegated: [LoadWalletOverviewUseCase] loads, [WalletLedger]
/// derives balances, [EmergencyFundAccess] gates the emergency fund, and
/// [WalletChangeEffects] tells other features about changes. The bottom
/// sheets are opened through the `WalletSheets` extension.
@lazySingleton
class WalletController extends CcGetController {
  WalletController(
    this._repository,
    this._loadOverview,
    this._ledger,
    this._emergencyFund,
    this.effects,
  );

  final WalletRepository _repository;
  final LoadWalletOverviewUseCase _loadOverview;
  final WalletLedger _ledger;
  final EmergencyFundAccess _emergencyFund;

  /// Cross-feature effects of wallet changes (also used by the sheets).
  final WalletChangeEffects effects;

  /// Kept for screens that still convert through this controller; new code
  /// injects [CurrencyConversionService] directly.
  CurrencyConversionService get conversionService => _ledger.conversionService;

  final RxInt currentNavIndex = 1.obs;
  final RxBool isBalanceVisible = true.obs;

  /// When true, the wallet list shows edit/delete affordances on each item.
  final RxBool isEditMode = false.obs;

  final RxBool isVip = false.obs;
  final RxString currencyCode = CurrencyConstants.defaultCurrencyCode.obs;
  final RxMap<String, int> displayBalances = <String, int>{}.obs;

  final RxList<WalletEntity> wallets = <WalletEntity>[].obs;
  final RxInt totalBalance = 0.obs;
  final RxInt liquidBalance = 0.obs;
  final RxInt investmentBalance = 0.obs;
  final RxInt emergencyFundBalance = 0.obs;
  final RxInt liabilityBalance = 0.obs;

  /// Monthly investment totals (current month).
  final RxInt monthlyInvested = 0.obs;
  final RxInt monthlyReturned = 0.obs;

  /// Monthly ROI: (Monthly Return - Monthly Contributed) / Monthly Contributed.
  final RxDouble monthlyRoiPercent = 0.0.obs;

  /// Monthly Breakeven: Monthly Return / Monthly Contributed.
  final RxDouble monthlyBreakevenPercent = 0.0.obs;

  /// All-time investment totals.
  final RxInt allTimeInvested = 0.obs;
  final RxInt allTimeReturned = 0.obs;

  /// Σ (Thu vào - Chi ra) ÷ Σ Chi ra across every investment position.
  final RxDouble investmentRoiPercent = 0.0.obs;

  /// Σ Thu vào ÷ Σ Chi ra across every investment position (Recovery rate).
  final RxDouble investmentBreakevenPercent = 0.0.obs;

  /// Ids of wallets that have at least one (non-deleted) transaction. Used to
  /// lock the opening balance once a wallet has activity.
  final Set<String> _walletsWithTxns = <String>{};

  /// Current (book) balance per wallet = opening balance ± transactions.
  /// This is what the UI shows, not [WalletEntity.balance] (the opening amount).
  final RxMap<String, int> _bookBalances = <String, int>{}.obs;

  final RxMap<String, InvestmentStats> _investmentStats =
      <String, InvestmentStats>{}.obs;
  final RxMap<String, InvestmentStats> _monthlyInvestmentStats =
      <String, InvestmentStats>{}.obs;

  bool _isTransactionDataDirty = true;

  /// The load in progress, if any.
  Future<void>? _loading;

  /// One load queued behind [_loading], shared by every call made meanwhile.
  Future<void>? _followUp;

  @override
  void onInit() {
    super.onInit();
    ever(
      CurrencyConstants.onCurrencyChanged,
      (_) => loadWallets(forceRefresh: true),
    );
  }

  @override
  void onReady() {
    super.onReady();
    loadWallets();
  }

  void toggleEditMode() => isEditMode.toggle();

  void toggleBalanceVisibility() => isBalanceVisible.toggle();

  void setNavIndex(int index) => currentNavIndex.value = index;

  bool walletHasTransactions(String id) => _walletsWithTxns.contains(id);

  int bookBalanceOf(String id) =>
      _bookBalances[id] ??
      wallets.firstWhereOrNull((w) => w.id == id)?.balance ??
      0;

  int displayBookBalanceOf(String id) =>
      displayBalances[id] ?? bookBalanceOf(id);

  InvestmentStats investmentStatsOf(String id) =>
      _investmentStats[id] ?? (contributed: 0, returned: 0);

  InvestmentStats monthlyInvestmentStatsOf(String id) =>
      _monthlyInvestmentStats[id] ?? (contributed: 0, returned: 0);

  List<WalletEntity> get liquidWallets => WalletOrdering.liquid(wallets);

  List<WalletEntity> get recentLiquidWallets =>
      WalletOrdering.recentLiquid(wallets);

  List<WalletEntity> get investmentWallets =>
      WalletOrdering.investment(wallets);

  List<WalletEntity> get recentInvestmentWallets =>
      WalletOrdering.recentInvestment(wallets);

  bool canDeleteWallet(WalletEntity wallet) => WalletOrdering.canDelete(wallet);

  /// Marks the transaction data dirty so the next [loadWallets] will recompute derived balances.
  void markDirty() {
    '[WalletController] 🧹 Wallet transaction data marked dirty'.Log(
      'WalletController',
    );
    _isTransactionDataDirty = true;
  }

  /// Reloads wallets and their derived book balances.
  ///
  /// Calls overlap often (several screens refresh after one save). While a
  /// load runs, further calls share one follow-up load instead of starting
  /// their own. The follow-up rebuilds balances only if [markDirty] was
  /// called after the running load read the transactions, so one change
  /// costs one rebuild.
  Future<void> loadWallets({
    bool showLoading = true,
    bool forceRefresh = false,
  }) {
    final running = _loading;
    if (running == null) {
      return _startLoad(showLoading: showLoading, forceRefresh: forceRefresh);
    }
    return _followUp ??= running.catchError((_) {}).then((_) {
      _followUp = null;
      return _startLoad(showLoading: false, forceRefresh: false);
    });
  }

  Future<void> _startLoad({
    required bool showLoading,
    required bool forceRefresh,
  }) {
    final load = _load(showLoading: showLoading, forceRefresh: forceRefresh);
    _loading = load;
    return load.whenComplete(() {
      if (identical(_loading, load)) _loading = null;
    });
  }

  Future<void> _load({
    required bool showLoading,
    required bool forceRefresh,
  }) async {
    if (showLoading) layoutStatus.value = CcLayoutStatus.loading;

    final result = await _loadOverview();
    if (result.isError()) {
      errorMessage.value = result.tryGetError()!.message;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }
    final (:settings, wallets: list) = result.tryGetSuccess()!;
    isVip.value = settings.isVip;
    final currencyChanged = currencyCode.value != settings.currencyCode;
    currencyCode.value = settings.currencyCode;

    if (_isTransactionDataDirty ||
        forceRefresh ||
        currencyChanged ||
        wallets.isEmpty) {
      '[WalletController] 🔄 Rebuilding derived balances | dirty=$_isTransactionDataDirty | force=$forceRefresh | currencyChanged=$currencyChanged | empty=${wallets.isEmpty}'
          .Log('WalletController');
      // Cleared before the ledger reads transactions: a markDirty() from here
      // on means data this build may miss, so the follow-up load rebuilds.
      _isTransactionDataDirty = false;
      try {
        final snapshot = await _ledger.build(list, currencyCode.value);
        _walletsWithTxns
          ..clear()
          ..addAll(snapshot.walletsWithTransactions);
        _bookBalances.assignAll(snapshot.bookBalances);
        _investmentStats.assignAll(snapshot.investmentStats);
        _monthlyInvestmentStats.assignAll(snapshot.monthlyInvestmentStats);
      } catch (_) {
        _isTransactionDataDirty = true;
        rethrow;
      }
    }
    wallets.assignAll(list);
    displayBalances.assignAll(
      await _ledger.displayBalances(list, bookBalanceOf, currencyCode.value),
    );
    _calculateTotalBalance();

    layoutStatus.value = CcLayoutStatus.success;
  }

  Future<void> reorderInvestments(int oldIndex, int newIndex) async {
    final items = investmentWallets;
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    for (int i = 0; i < items.length; i++) {
      final updated = items[i].copyWith(
        displayOrder: i,
        updatedAt: DateTime.now(),
      );
      await _repository.updateWallet(updated);

      final localIdx = wallets.indexWhere((w) => w.id == updated.id);
      if (localIdx != -1) wallets[localIdx] = updated;
    }

    _calculateTotalBalance();
  }

  Future<void> addWallet({
    required String name,
    required int initialBalance,
    required int iconCode,
    required String type,
    String? categoryId,
  }) async {
    if (type == WalletType.emergencyFund &&
        !await _emergencyFund.isUnlocked()) {
      errorMessage.value = el.tr(
        CcLocaleKeys.wallet_emergency_fund_locked_hint,
      );
      return;
    }

    final now = DateTime.now();
    final newWallet = WalletEntity(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      balance: initialBalance,
      iconCode: iconCode,
      type: type,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
      displayOrder: wallets.length,
      currencyCode: currencyCode.value,
    );

    final result = await _repository.addWallet(newWallet);
    result.when((_) {
      wallets.add(newWallet);
      _bookBalances[newWallet.id] = newWallet.balance;
      _calculateTotalBalance();
      layoutStatus.value = CcLayoutStatus.success;
      effects.added(newWallet);
    }, (error) => errorMessage.value = error.message);
  }

  Future<void> updateWallet(WalletEntity wallet) async {
    final index = wallets.indexWhere((e) => e.id == wallet.id);
    final original = index != -1 ? wallets[index] : null;
    // Once a wallet has activity its opening balance and currency are fixed.
    final keepOpening =
        original != null &&
        walletHasTransactions(wallet.id) &&
        bookBalanceOf(wallet.id) != 0;
    final toSave = WalletEntity(
      id: wallet.id,
      name: wallet.name,
      balance: keepOpening ? original.balance : wallet.balance,
      iconCode: wallet.iconCode,
      type: wallet.type,
      createdAt: wallet.createdAt,
      updatedAt: DateTime.now(),
      categoryId: wallet.categoryId,
      currencyCode: keepOpening ? original.currencyCode : wallet.currencyCode,
    );

    final result = await _repository.updateWallet(toSave);
    result.when((_) {
      if (original == null) return;
      _bookBalances[wallet.id] =
          bookBalanceOf(wallet.id) + (toSave.balance - original.balance);
      wallets[index] = toSave;
      _calculateTotalBalance();
      effects.updated(toSave, original);
    }, (error) => errorMessage.value = error.message);
  }

  Future<WalletDeleteOutcome> deleteWallet(String id) async {
    final wallet = wallets.firstWhereOrNull((w) => w.id == id);
    if (wallet == null) return WalletDeleteOutcome.error;
    if (!canDeleteWallet(wallet)) return WalletDeleteOutcome.protected;
    if (wallet.type != WalletType.investment && _walletsWithTxns.contains(id)) {
      return WalletDeleteOutcome.notEmpty;
    }

    final softDelete = await _ledger.removeTransactionsOf(id);
    if (softDelete.isError()) {
      errorMessage.value = softDelete.tryGetError()!.message;
      return WalletDeleteOutcome.error;
    }
    final result = await _repository.deleteWallet(id);
    if (result.isError()) {
      errorMessage.value = result.tryGetError()!.message;
      return WalletDeleteOutcome.error;
    }

    wallets.removeWhere((e) => e.id == id);
    _walletsWithTxns.remove(id);
    _bookBalances.remove(id);
    _calculateTotalBalance();
    effects.removed(id);

    layoutStatus.value = wallets.isEmpty
        ? CcLayoutStatus.empty
        : CcLayoutStatus.success;
    return WalletDeleteOutcome.success;
  }

  void _calculateTotalBalance() {
    final totals = WalletTotals.of(
      wallets,
      displayBalanceOf: displayBookBalanceOf,
      statsOf: investmentStatsOf,
      monthlyStatsOf: monthlyInvestmentStatsOf,
    );
    totalBalance.value = totals.total;
    liquidBalance.value = totals.liquid;
    investmentBalance.value = totals.allTimeInvested;
    allTimeInvested.value = totals.allTimeInvested;
    allTimeReturned.value = totals.allTimeReturned;
    monthlyInvested.value = totals.monthlyInvested;
    monthlyReturned.value = totals.monthlyReturned;
    investmentRoiPercent.value = totals.roiPercent;
    investmentBreakevenPercent.value = totals.breakevenPercent;
    monthlyRoiPercent.value = totals.monthlyRoiPercent;
    monthlyBreakevenPercent.value = totals.monthlyBreakevenPercent;
    emergencyFundBalance.value = totals.emergencyFund;
    liabilityBalance.value = 0;
  }
}
