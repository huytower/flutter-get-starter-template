import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/helper/budget_name_helper.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../profile/user_level/presentation/get_x/user_level_controller.dart';
import '../../../reconciliation/presentation/get_x/reconciliation_controller.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/presentation/get_x/transaction_controller.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/get_investment_roi_usecase.dart';
import '../../domain/usecases/get_wallet_book_balance_usecase.dart';
import '../widgets/add_liquid_sheet.dart';
import '../widgets/investment_delete_confirm_sheet.dart';
import '../widgets/wallet_delete_confirm_sheet.dart';

/// Outcome of a wallet deletion attempt (rule: only empty wallets deletable).
enum WalletDeleteOutcome { success, notEmpty, protected, error }

@lazySingleton
class WalletController extends CcGetController {
  WalletController(
    this._repository,
    this._transactionRepository,
    this._getWalletBookBalance,
    this._getInvestmentRoi,
    this._getProfileSettings,
    this._conversionService,
  ) : _categoryRepository = getIt<CategoryRepository>();

  final WalletRepository _repository;
  final TransactionRepository _transactionRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;
  final GetInvestmentRoiUseCase _getInvestmentRoi;
  final GetProfileSettingsUseCase _getProfileSettings;
  final CurrencyConversionService _conversionService;
  final CategoryRepository _categoryRepository;

  CurrencyConversionService get conversionService => _conversionService;

  final RxInt currentNavIndex = 1.obs;
  final RxBool isBalanceVisible = true.obs;

  /// When true, the wallet list shows edit/delete affordances on each item.
  final RxBool isEditMode = false.obs;

  final RxBool isVip = false.obs;
  final RxString currencyCode = CurrencyConstants.defaultCurrencyCode.obs;
  final RxMap<String, int> displayBalances = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    ever(CurrencyConstants.onCurrencyChanged, (_) => loadWallets());
  }

  void toggleEditMode() {
    isEditMode.toggle();
  }

  void onCloseEditMode(BuildContext context) {
    if (isEditMode.value) {
      isEditMode.value = false;
    } else {
      Navigator.of(context).pop();
    }
  }

  void openForm(BuildContext context, {WalletEntity? wallet}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddLiquidSheet(wallet: wallet),
    );
  }

  void confirmDelete(BuildContext context, WalletEntity wallet) {
    if (wallet.type == WalletType.investment) {
      final stats = investmentStatsOf(wallet.id);
      if (stats.contributed == 0 && stats.returned == 0) {
        deleteWallet(wallet.id).then((outcome) {
          _handleDeleteOutcome(null, outcome);
        });
        return;
      }
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        if (wallet.type == WalletType.investment) {
          return InvestmentDeleteConfirmSheet(
            wallet: wallet,
            onDelete: () => deleteWallet(wallet.id),
            onOutcome: (outcome) => _handleDeleteOutcome(context, outcome),
          );
        }
        return WalletDeleteConfirmSheet(
          wallet: wallet,
          onDelete: () => deleteWallet(wallet.id),
          onOutcome: (outcome) => _handleDeleteOutcome(context, outcome),
        );
      },
    );
  }

  void _handleDeleteOutcome(
    BuildContext? context,
    WalletDeleteOutcome outcome,
  ) {
    final activeContext = (context != null && context.mounted)
        ? context
        : Get.context;
    if (activeContext == null) return;

    switch (outcome) {
      case WalletDeleteOutcome.success:
        if (Get.isRegistered<ReconciliationController>()) {
          Get.find<ReconciliationController>().loadBalances();
        }
        CcSnackBarHelper.showSuccessSnackBar(
          context: activeContext,
          message: el.tr(CcLocaleKeys.common_done),
        );
        break;
      case WalletDeleteOutcome.notEmpty:
        CcSnackBarHelper.showErrorSnackBar(
          context: activeContext,
          message: el.tr(CcLocaleKeys.wallet_delete_error_not_empty),
        );
        break;
      case WalletDeleteOutcome.protected:
        CcSnackBarHelper.showErrorSnackBar(
          context: activeContext,
          message: el.tr(CcLocaleKeys.wallet_delete_error_protected),
        );
        break;
      case WalletDeleteOutcome.error:
        CcSnackBarHelper.showErrorSnackBar(
          context: activeContext,
          message: errorMessage.value.isNotEmpty
              ? errorMessage.value
              : el.tr(CcLocaleKeys.app_error_general),
        );
        break;
    }
  }

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

  int _investmentReturnsTotal = 0;

  /// Ids of wallets that have at least one (non-deleted) transaction. Used to
  /// lock the opening balance once a wallet has activity.
  final Set<String> _walletsWithTxns = <String>{};

  bool walletHasTransactions(String id) => _walletsWithTxns.contains(id);

  /// Current (book) balance per wallet = opening balance ± transactions.
  /// This is what the UI shows, not [WalletEntity.balance] (the opening amount).
  final RxMap<String, int> _bookBalances = <String, int>{}.obs;

  int bookBalanceOf(String id) => _bookBalances[id] ?? 0;

  int displayBookBalanceOf(String id) =>
      displayBalances[id] ?? bookBalanceOf(id);

  /// Performance stats for investment wallets: (capital contributed, profit returned).
  final RxMap<String, ({int contributed, int returned})> _investmentStats =
      <String, ({int contributed, int returned})>{}.obs;

  final RxMap<String, ({int contributed, int returned})>
  _monthlyInvestmentStats = <String, ({int contributed, int returned})>{}.obs;

  ({int contributed, int returned}) investmentStatsOf(String id) =>
      _investmentStats[id] ?? (contributed: 0, returned: 0);

  ({int contributed, int returned}) monthlyInvestmentStatsOf(String id) =>
      _monthlyInvestmentStats[id] ?? (contributed: 0, returned: 0);

  static const List<String> _liquidTypeOrder = [
    WalletType.cash,
    WalletType.bank,
    WalletType.ewallet,
    WalletType.emergencyFund,
  ];

  List<WalletEntity> get liquidWallets {
    final liquid = wallets
        .where((w) => _liquidTypeOrder.contains(w.type))
        .toList();
    liquid.sort((a, b) {
      if (a.type == WalletType.cash && b.type != WalletType.cash) return -1;
      if (b.type == WalletType.cash && a.type != WalletType.cash) return 1;

      final defaultBankName = el.tr(CcLocaleKeys.wallet_bank);
      if (a.type == WalletType.bank &&
          a.name == defaultBankName &&
          b.type != WalletType.cash) {
        if (b.type == WalletType.bank && b.name != defaultBankName) return -1;
        return -1;
      }
      if (b.type == WalletType.bank &&
          b.name == defaultBankName &&
          a.type != WalletType.cash) {
        if (a.type == WalletType.bank && a.name != defaultBankName) return 1;
        return 1;
      }

      final typeCompare = _liquidTypeOrder
          .indexOf(a.type)
          .compareTo(_liquidTypeOrder.indexOf(b.type));
      if (typeCompare != 0) return typeCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return liquid;
  }

  List<WalletEntity> get recentLiquidWallets {
    final liquid = wallets
        .where((w) => _liquidTypeOrder.contains(w.type))
        .toList();
    liquid.sort((a, b) {
      if (a.type == WalletType.cash) return -1;
      if (b.type == WalletType.cash) return 1;
      return 0;
    });
    return liquid;
  }

  List<WalletEntity> get investmentWallets {
    final investment = wallets
        .where((w) => w.type == WalletType.investment)
        .toList();
    final unique = <String, WalletEntity>{};
    for (final w in investment) {
      unique[w.id] = w;
    }
    final result = unique.values.toList();
    result.sort((a, b) {
      if (a.displayOrder != b.displayOrder) {
        return a.displayOrder.compareTo(b.displayOrder);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return _dedupByDisplayName(result);
  }

  List<WalletEntity> get recentInvestmentWallets {
    final investment = wallets
        .where((w) => w.type == WalletType.investment)
        .toList();
    final unique = <String, WalletEntity>{};
    for (final w in investment) {
      unique[w.id] = w;
    }
    final result = unique.values.toList();
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _dedupByDisplayName(result);
  }

  List<WalletEntity> _dedupByDisplayName(List<WalletEntity> wallets) {
    final seen = <String, WalletEntity>{};
    for (final w in wallets) {
      final displayName = BudgetNameHelper.getDisplayName(
        name: w.name,
        categoryNameKey: w.categoryNameKey,
      );
      seen.putIfAbsent(displayName, () => w);
    }
    return seen.values.toList();
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

  bool canDeleteWallet(WalletEntity wallet) {
    if (wallet.type == WalletType.cash) return false;
    if (wallet.type == WalletType.bank) {
      final defaultBankName = el.tr(CcLocaleKeys.wallet_bank);
      if (wallet.name == defaultBankName) return false;
    }
    return true;
  }

  @override
  void onReady() {
    super.onReady();
    loadWallets();
  }

  bool _isTransactionDataDirty = true;

  /// Marks the transaction data dirty so the next [loadWallets] will recompute derived balances.
  void markDirty() {
    '[WalletController] 🧹 Wallet transaction data marked dirty'.Log(
      'WalletController',
    );
    _isTransactionDataDirty = true;
  }

  /// Reloads wallets and their derived book balances.
  Future<void> loadWallets({
    bool showLoading = true,
    bool forceRefresh = false,
  }) async {
    if (showLoading) {
      layoutStatus.value = CcLayoutStatus.loading;
    }

    final settings = await _getProfileSettings();
    isVip.value = settings.isVip;
    currencyCode.value = settings.currencyCode;

    final result = await _repository.getWallets();

    if (result.isError()) {
      errorMessage.value = result.tryGetError()!.message;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }

    final catResult = await _categoryRepository.getCategories();
    final categories = catResult.tryGetSuccess() ?? <CategoryEntity>[];

    final list = result
        .tryGetSuccess()!
        .map((w) {
          if (w.categoryId != null) {
            final cat = categories.firstWhereOrNull(
              (c) => c.id == w.categoryId,
            );
            return w.copyWith(categoryNameKey: cat?.nameKey);
          }
          return w;
        })
        .toList()
        .cast<WalletEntity>();

    if (_isTransactionDataDirty || forceRefresh || wallets.isEmpty) {
      '[WalletController] 🔄 Rebuilding derived balances | dirty=$_isTransactionDataDirty | force=$forceRefresh | empty=${wallets.isEmpty}'
          .Log('WalletController');
      await _rebuildDerivedBalances(list);
      _isTransactionDataDirty = false;
    } else {
      '[WalletController] ⚡ Serving cached wallet balances (0ms DB skip) | dirty=$_isTransactionDataDirty'
          .Log('WalletController');
    }
    wallets.assignAll(list);
    await _rebuildDisplayBalances(list);
    _calculateTotalBalance();

    layoutStatus.value = CcLayoutStatus.success;
  }

  /// Fetches transactions once and derives, per wallet, both the activity flag
  /// and current book balance concurrently using [Future.wait].
  Future<void> _rebuildDerivedBalances(List<WalletEntity> list) async {
    final result = await _transactionRepository.getListTransactions();
    final txns = result.when((t) => t, (_) => <TransactionEntity>[]);
    '[WalletController] 📊 _rebuildDerivedBalances executed for ${list.length} wallets | txnsLength=${txns.length}'
        .Log('WalletController');
    final targetCurrency = currencyCode.value;

    _walletsWithTxns
      ..clear()
      ..addAll(txns.map((t) => t.walletId));

    final newBalances = <String, int>{};
    final newStats = <String, ({int contributed, int returned})>{};
    final monthlyStatsMap = <String, ({int contributed, int returned})>{};

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    await Future.wait(
      list.map((wallet) async {
        final walletTxns = txns.where((t) => t.walletId == wallet.id).toList();
        var walletBookBal = wallet.balance;

        final txnConvertedAmounts = await Future.wait(
          walletTxns.map((txn) async {
            if (txn.currencyCode.toUpperCase() !=
                wallet.currencyCode.toUpperCase()) {
              final converted = await _conversionService.convertAmount(
                amount: txn.amount,
                fromCurrency: txn.currencyCode,
                toCurrency: wallet.currencyCode,
              );
              return converted.tryGetSuccess() ?? txn.amount;
            }
            return txn.amount;
          }),
        );

        for (int i = 0; i < walletTxns.length; i++) {
          final txn = walletTxns[i];
          final amountInWalletCurrency = txnConvertedAmounts[i];

          switch (txn.type) {
            case TransactionType.income:
            case TransactionType.transferIn:
            case TransactionType.investmentIn:
            case TransactionType.investmentReturn:
            case TransactionType.debtBorrow:
            case TransactionType.debtCollect:
              walletBookBal += amountInWalletCurrency;
              break;
            case TransactionType.expense:
            case TransactionType.transferOut:
            case TransactionType.investmentOut:
            case TransactionType.debtLend:
            case TransactionType.debtRepay:
              walletBookBal -= amountInWalletCurrency;
              break;
          }
        }
        newBalances[wallet.id] = walletBookBal;

        if (wallet.type == WalletType.investment) {
          final invInTxns = txns
              .where(
                (t) =>
                    t.investmentWalletId == wallet.id &&
                    t.type == TransactionType.investmentIn,
              )
              .toList();

          final invReturnTxns = txns
              .where(
                (t) =>
                    t.investmentWalletId == wallet.id &&
                    t.type == TransactionType.investmentReturn,
              )
              .toList();

          final monthlyInvInTxns = invInTxns
              .where((t) => t.date.isAfter(monthStart))
              .toList();

          final monthlyInvReturnTxns = invReturnTxns
              .where((t) => t.date.isAfter(monthStart))
              .toList();

          final convertedAllIn = await Future.wait(
            invInTxns.map((t) async {
              final conv = await _conversionService.convertAmount(
                amount: t.amount,
                fromCurrency: t.currencyCode,
                toCurrency: targetCurrency,
              );
              return conv.tryGetSuccess() ?? t.amount;
            }),
          );

          final convertedAllReturn = await Future.wait(
            invReturnTxns.map((t) async {
              final conv = await _conversionService.convertAmount(
                amount: t.amount,
                fromCurrency: t.currencyCode,
                toCurrency: targetCurrency,
              );
              return conv.tryGetSuccess() ?? t.amount;
            }),
          );

          final convertedMonthlyIn = await Future.wait(
            monthlyInvInTxns.map((t) async {
              final conv = await _conversionService.convertAmount(
                amount: t.amount,
                fromCurrency: t.currencyCode,
                toCurrency: targetCurrency,
              );
              return conv.tryGetSuccess() ?? t.amount;
            }),
          );

          final convertedMonthlyReturn = await Future.wait(
            monthlyInvReturnTxns.map((t) async {
              final conv = await _conversionService.convertAmount(
                amount: t.amount,
                fromCurrency: t.currencyCode,
                toCurrency: targetCurrency,
              );
              return conv.tryGetSuccess() ?? t.amount;
            }),
          );

          final allTimeContributed = convertedAllIn.fold<int>(
            0,
            (sum, amt) => sum + amt,
          );

          final allTimeReturned = convertedAllReturn.fold<int>(
            0,
            (sum, amt) => sum + amt,
          );

          final monthlyContributed = convertedMonthlyIn.fold<int>(
            0,
            (sum, amt) => sum + amt,
          );

          final monthlyReturned = convertedMonthlyReturn.fold<int>(
            0,
            (sum, amt) => sum + amt,
          );

          newStats[wallet.id] = (
            contributed: allTimeContributed,
            returned: allTimeReturned,
          );

          monthlyStatsMap[wallet.id] = (
            contributed: monthlyContributed,
            returned: monthlyReturned,
          );
        }
      }),
    );

    _bookBalances.assignAll(newBalances);
    _investmentStats.assignAll(newStats);
    _monthlyInvestmentStats.assignAll(monthlyStatsMap);

    _investmentReturnsTotal = txns
        .where(
          (t) =>
              t.type == TransactionType.investmentReturn &&
              t.investmentWalletId != null,
        )
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Rebuilds display balances concurrently using [Future.wait].
  Future<void> _rebuildDisplayBalances(List<WalletEntity> list) async {
    final targetCurrency = currencyCode.value;

    final entries = await Future.wait(
      list.map((wallet) async {
        final raw = bookBalanceOf(wallet.id);
        final result = await _conversionService.convertAmount(
          amount: raw,
          fromCurrency: wallet.currencyCode,
          toCurrency: targetCurrency,
        );
        final convertedVal = result.tryGetSuccess() ?? raw;
        return MapEntry(wallet.id, convertedVal);
      }),
    );

    displayBalances.assignAll(Map.fromEntries(entries));
  }

  void _calculateTotalBalance() {
    totalBalance.value = wallets.fold(
      0,
      (sum, item) => sum + displayBookBalanceOf(item.id),
    );

    liquidBalance.value = wallets
        .where(
          (w) =>
              w.type == WalletType.cash ||
              w.type == WalletType.bank ||
              w.type == WalletType.ewallet,
        )
        .fold(0, (sum, item) => sum + displayBookBalanceOf(item.id));

    int totalInvestedValue = 0;
    int totalReturnedValue = 0;
    int monthlyInvestedValue = 0;
    int monthlyReturnedValue = 0;

    for (final wallet in wallets) {
      if (wallet.type == WalletType.investment) {
        final stats = investmentStatsOf(wallet.id);
        totalInvestedValue += stats.contributed;
        totalReturnedValue += stats.returned;

        final mStats = monthlyInvestmentStatsOf(wallet.id);
        monthlyInvestedValue += mStats.contributed;
        monthlyReturnedValue += mStats.returned;
      }
    }

    investmentBalance.value = totalInvestedValue;
    allTimeInvested.value = totalInvestedValue;
    allTimeReturned.value = totalReturnedValue;

    monthlyInvested.value = monthlyInvestedValue;
    monthlyReturned.value = monthlyReturnedValue;

    // All-time ROI & Breakeven
    if (totalInvestedValue == 0) {
      investmentRoiPercent.value = 0;
      investmentBreakevenPercent.value = 0;
    } else {
      investmentRoiPercent.value =
          ((totalReturnedValue - totalInvestedValue) / totalInvestedValue) *
          100;
      investmentBreakevenPercent.value =
          (totalReturnedValue / totalInvestedValue) * 100;
    }

    // Monthly ROI & Breakeven
    if (monthlyInvestedValue == 0 || monthlyReturnedValue == 0) {
      monthlyRoiPercent.value = 0;
      monthlyBreakevenPercent.value = 0;
    } else {
      monthlyRoiPercent.value =
          ((monthlyReturnedValue - monthlyInvestedValue) /
              monthlyInvestedValue) *
          100;
      monthlyBreakevenPercent.value =
          (monthlyReturnedValue / monthlyInvestedValue) * 100;
    }

    emergencyFundBalance.value = wallets
        .where((w) => w.type == WalletType.emergencyFund)
        .fold(0, (sum, item) => sum + displayBookBalanceOf(item.id));

    liabilityBalance.value = 0;
  }

  Future<void> addWallet({
    required String name,
    required int initialBalance,
    required int iconCode,
    required String type,
    String? categoryId,
  }) async {
    if (type == WalletType.emergencyFund) {
      final status = getIt<UserLevelController>().status.value;
      final settings = await getIt<GetProfileSettingsUseCase>().call();
      final unlocked =
          settings.isVip ||
          (status.level >= 3 && settings.hasViewedEmergencyFundEbook);
      if (!unlocked) {
        errorMessage.value = el.tr(
          CcLocaleKeys.wallet_emergency_fund_locked_hint,
        );
        return;
      }
    }

    final newWallet = WalletEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      balance: initialBalance,
      iconCode: iconCode,
      type: type,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      displayOrder: wallets.length,
      currencyCode: currencyCode.value,
    );

    final result = await _repository.addWallet(newWallet);

    result.when(
      (success) {
        wallets.add(newWallet);
        _bookBalances[newWallet.id] = newWallet.balance;
        _calculateTotalBalance();
        layoutStatus.value = CcLayoutStatus.success;

        if (Get.isRegistered<TransactionController>()) {
          Get.find<TransactionController>().wallets.add(newWallet);
        }
      },
      (error) {
        errorMessage.value = error.message;
      },
    );
  }

  Future<void> updateWallet(WalletEntity wallet) async {
    var toSave = wallet;
    final index = wallets.indexWhere((e) => e.id == wallet.id);
    final original = index != -1 ? wallets[index] : null;
    if (original != null &&
        walletHasTransactions(wallet.id) &&
        bookBalanceOf(wallet.id) != 0) {
      toSave = WalletEntity(
        id: wallet.id,
        name: wallet.name,
        balance: original.balance,
        iconCode: wallet.iconCode,
        type: wallet.type,
        createdAt: wallet.createdAt,
        updatedAt: DateTime.now(),
        categoryId: wallet.categoryId,
        currencyCode: original.currencyCode,
      );
    } else {
      toSave = WalletEntity(
        id: wallet.id,
        name: wallet.name,
        balance: wallet.balance,
        iconCode: wallet.iconCode,
        type: wallet.type,
        createdAt: wallet.createdAt,
        updatedAt: DateTime.now(),
        categoryId: wallet.categoryId,
        currencyCode: wallet.currencyCode,
      );
    }

    final result = await _repository.updateWallet(toSave);

    result.when(
      (success) {
        if (original != null) {
          _bookBalances[wallet.id] =
              bookBalanceOf(wallet.id) + (toSave.balance - original.balance);
          wallets[index] = toSave;
          _calculateTotalBalance();

          if (toSave.balance > 0) {
            Get.find<GuidelineController>().completeTask('wallet_balance');
          }

          if (wallet.type == WalletType.cash &&
              toSave.balance != original.balance) {
            Get.find<GuidelineController>().completeTask('wallet_balance');
          }
        }
      },
      (error) {
        errorMessage.value = error.message;
      },
    );
  }

  Future<WalletDeleteOutcome> deleteWallet(String id) async {
    final index = wallets.indexWhere((w) => w.id == id);
    if (index == -1) return WalletDeleteOutcome.error;
    final wallet = wallets[index];

    if (!canDeleteWallet(wallet)) {
      return WalletDeleteOutcome.protected;
    }

    if (wallet.type == WalletType.investment) {
      // Deletable
    } else {
      if (_walletsWithTxns.contains(id)) {
        return WalletDeleteOutcome.notEmpty;
      }
    }

    final softDelete = await _transactionRepository.softDeleteByWallet(id);
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

    if (Get.isRegistered<TransactionController>()) {
      Get.find<TransactionController>().wallets.removeWhere((e) => e.id == id);
    }

    layoutStatus.value = wallets.isEmpty
        ? CcLayoutStatus.empty
        : CcLayoutStatus.success;
    return WalletDeleteOutcome.success;
  }

  void toggleBalanceVisibility() {
    isBalanceVisible.value = !isBalanceVisible.value;
  }

  void setNavIndex(int index) {
    currentNavIndex.value = index;
  }
}
