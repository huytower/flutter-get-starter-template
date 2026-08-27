import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../reconciliation/presentation/get_x/reconciliation_controller.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/presentation/get_x/transaction_controller.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/get_investment_roi_usecase.dart';
import '../../domain/usecases/get_wallet_book_balance_usecase.dart';
import '../../domain/usecases/wallet_balance_calculator.dart';
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
  );

  final WalletRepository _repository;
  final TransactionRepository _transactionRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;
  final GetInvestmentRoiUseCase _getInvestmentRoi;
  final GetProfileSettingsUseCase _getProfileSettings;

  final RxInt currentNavIndex = 1.obs;
  final RxBool isBalanceVisible = true.obs;

  /// When true, the wallet list shows edit/delete affordances on each item.
  final RxBool isEditMode = false.obs;

  final RxBool isVip = false.obs;

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

  /// Σ realized Thu vào not already reflected in any wallet's own book
  /// balance — added on top of [investmentBalance] so that card still reads
  /// as "capital + profit" even though profit now lands in a liquid wallet.
  /// Only counts new-style records (`investmentWalletId != null`); older
  /// records (written before this field existed) still have `walletId`
  /// pointing at the investment wallet itself, so they're already counted
  /// once via that wallet's own book balance — counting them here too would
  /// double them up.
  int _investmentReturnsTotal = 0;

  /// Ids of wallets that have at least one (non-deleted) transaction. Used to
  /// lock the opening balance once a wallet has activity.
  final Set<String> _walletsWithTxns = <String>{};

  bool walletHasTransactions(String id) => _walletsWithTxns.contains(id);

  /// Current (book) balance per wallet = opening balance ± transactions.
  /// This is what the UI shows, not [WalletEntity.balance] (the opening amount).
  final RxMap<String, int> _bookBalances = <String, int>{}.obs;

  int bookBalanceOf(String id) => _bookBalances[id] ?? 0;

  /// Performance stats for investment wallets: (capital contributed, profit returned).
  final RxMap<String, ({int contributed, int returned})> _investmentStats =
      <String, ({int contributed, int returned})>{}.obs;

  final RxMap<String, ({int contributed, int returned})>
  _monthlyInvestmentStats = <String, ({int contributed, int returned})>{}.obs;

  ({int contributed, int returned}) investmentStatsOf(String id) =>
      _investmentStats[id] ?? (contributed: 0, returned: 0);

  ({int contributed, int returned}) monthlyInvestmentStatsOf(String id) =>
      _monthlyInvestmentStats[id] ?? (contributed: 0, returned: 0);

  /// Type order for the Budget Allocation screen's "Ví của bạn" strip: cash
  /// → bank → e-wallet → emergency fund. (Credit-card wallets aren't a
  /// [WalletType] yet; add them here, between bank and e-wallet, if that
  /// type is introduced.) Investment wallets are excluded; they get their
  /// own hero banner instead.
  static const List<String> _liquidTypeOrder = [
    WalletType.cash,
    WalletType.bank,
    WalletType.ewallet,
    WalletType.emergencyFund,
  ];

  /// Liquid wallets for the Budget Allocation screen's "Ví của bạn" strip,
  /// ordered per [_liquidTypeOrder]; wallets of the same type sort by name
  /// A-Z/0-9.
  List<WalletEntity> get liquidWallets {
    final liquid = wallets
        .where((w) => _liquidTypeOrder.contains(w.type))
        .toList();
    liquid.sort((a, b) {
      final typeCompare = _liquidTypeOrder
          .indexOf(a.type)
          .compareTo(_liquidTypeOrder.indexOf(b.type));
      if (typeCompare != 0) return typeCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return liquid;
  }

  /// Liquid wallets for the dashboard. Pins "Cash" to index 0 and keeps the
  /// rest in their original order (no strict sorting by name or date).
  List<WalletEntity> get recentLiquidWallets {
    final liquid = wallets
        .where((w) => _liquidTypeOrder.contains(w.type))
        .toList();
    liquid.sort((a, b) {
      if (a.type == WalletType.cash) return -1;
      if (b.type == WalletType.cash) return 1;
      return 0; // Stable sort: preserves relative order of other items
    });
    return liquid;
  }

  /// Investment wallets for the Budget Allocation screen.
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
    return result;
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
    return result;
  }

  /// Manually reorders investment assets (drag-and-drop).
  Future<void> reorderInvestments(int oldIndex, int newIndex) async {
    final items = investmentWallets;
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Persist new orders
    for (int i = 0; i < items.length; i++) {
      final updated = items[i].copyWith(
        displayOrder: i,
        updatedAt: DateTime.now(),
      );
      await _repository.updateWallet(updated);

      // Update local 'wallets' list
      final localIdx = wallets.indexWhere((w) => w.id == updated.id);
      if (localIdx != -1) wallets[localIdx] = updated;
    }

    _calculateTotalBalance();
  }

  /// Protected wallets can be renamed but never deleted:
  /// - the `cash` wallet is a fixed singleton, and
  /// - at least one `bank` account must always remain (mandatory).
  bool canDeleteWallet(WalletEntity wallet) {
    if (wallet.type == WalletType.cash) return false;
    if (wallet.type == WalletType.bank) {
      final bankCount = wallets.where((w) => w.type == WalletType.bank).length;
      if (bankCount <= 1) return false;
    }
    return true;
  }

  @override
  void onReady() {
    super.onReady();
    loadWallets();
  }

  /// Reloads wallets and their derived book balances.
  ///
  /// Pass [showLoading] false for background refreshes (e.g. re-opening the
  /// Wallet tab after adding a transaction elsewhere) so the list isn't
  /// replaced by a full-screen loader.
  Future<void> loadWallets() async {
    layoutStatus.value = CcLayoutStatus.loading;

    final settings = await _getProfileSettings();
    isVip.value = settings.isVip;

    final result = await _repository.getWallets();

    if (result.isError()) {
      errorMessage.value = result.tryGetError()!.message;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }

    final list = result.tryGetSuccess()!;
    await _rebuildDerivedBalances(list);
    wallets.assignAll(list);
    _calculateTotalBalance();

    layoutStatus.value = CcLayoutStatus.success;
  }

  /// Fetches transactions once and derives, per wallet, both the activity flag
  /// (rule 1) and the current book balance shown in the UI.
  Future<void> _rebuildDerivedBalances(List<WalletEntity> list) async {
    final result = await _transactionRepository.getListTransactions();
    final txns = result.when((t) => t, (_) => <TransactionEntity>[]);

    _walletsWithTxns
      ..clear()
      ..addAll(txns.map((t) => t.walletId));

    final newBalances = <String, int>{};
    final newStats = <String, ({int contributed, int returned})>{};
    final monthlyStatsMap = <String, ({int contributed, int returned})>{};

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    for (final wallet in list) {
      final walletTxns = txns.where((t) => t.walletId == wallet.id).toList();
      newBalances[wallet.id] = bookBalanceFromTransactions(
        wallet.balance,
        walletTxns,
      );

      if (wallet.type == WalletType.investment) {
        final allTimeContributed =
            txns
                .where(
                  (t) =>
                      t.investmentWalletId == wallet.id &&
                      t.type == TransactionType.investmentIn,
                )
                .fold(0, (sum, t) => sum + t.amount) +
            wallet.balance;

        final allTimeReturned = txns
            .where(
              (t) =>
                  t.investmentWalletId == wallet.id &&
                  t.type == TransactionType.investmentReturn,
            )
            .fold(0, (sum, t) => sum + t.amount);

        newStats[wallet.id] = (
          contributed: allTimeContributed,
          returned: allTimeReturned,
        );

        final monthlyContributed = txns
            .where(
              (t) =>
                  t.investmentWalletId == wallet.id &&
                  t.type == TransactionType.investmentIn &&
                  t.date.isAfter(monthStart),
            )
            .fold(0, (sum, t) => sum + t.amount);

        final monthlyReturned = txns
            .where(
              (t) =>
                  t.investmentWalletId == wallet.id &&
                  t.type == TransactionType.investmentReturn &&
                  t.date.isAfter(monthStart),
            )
            .fold(0, (sum, t) => sum + t.amount);

        monthlyStatsMap[wallet.id] = (
          contributed: monthlyContributed,
          returned: monthlyReturned,
        );
      }
    }
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

  void _calculateTotalBalance() {
    totalBalance.value = wallets.fold(
      0,
      (sum, item) => sum + bookBalanceOf(item.id),
    );

    liquidBalance.value = wallets
        .where(
          (w) =>
              w.type == WalletType.cash ||
              w.type == WalletType.bank ||
              w.type == WalletType.ewallet,
        )
        .fold(0, (sum, item) => sum + bookBalanceOf(item.id));

    int totalInvested = 0;
    int totalReturned = 0;
    for (final wallet in wallets) {
      if (wallet.type == WalletType.investment) {
        final stats = investmentStatsOf(wallet.id);
        totalInvested += stats.contributed;
        totalReturned += stats.returned;
      }
    }

    investmentBalance.value = totalInvested;
    if (totalInvested == 0) {
      investmentRoiPercent.value = 0;
      investmentBreakevenPercent.value = 0;
    } else {
      investmentRoiPercent.value =
          ((totalReturned - totalInvested) / totalInvested) * 100;
      investmentBreakevenPercent.value = (totalReturned / totalInvested) * 100;
    }

    emergencyFundBalance.value = wallets
        .where((w) => w.type == WalletType.emergencyFund)
        .fold(0, (sum, item) => sum + bookBalanceOf(item.id));

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
      final level = getIt<UserLevelController>().status.value.level;
      final settings = await getIt<GetProfileSettingsUseCase>().call();
      if (level < 2 || !settings.hasViewedEmergencyFundEbook) {
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
    // Rule 1: the opening balance may only change while the wallet has no
    // transactions. Once it has activity, preserve the original balance so the
    // book balance stays consistent — the name is still updatable.
    var toSave = wallet;
    final index = wallets.indexWhere((e) => e.id == wallet.id);
    final original = index != -1 ? wallets[index] : null;
    if (original != null && walletHasTransactions(wallet.id)) {
      toSave = WalletEntity(
        id: wallet.id,
        name: wallet.name,
        balance: original.balance,
        iconCode: wallet.iconCode,
        type: wallet.type,
        createdAt: wallet.createdAt,
        updatedAt: DateTime.now(),
        categoryId: wallet.categoryId,
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
      );
    }

    final result = await _repository.updateWallet(toSave);

    result.when(
      (success) {
        if (original != null) {
          // Shifting the opening balance shifts the book balance by the same
          // delta (0 when the balance was locked/unchanged).
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

  /// Investment wallets can always be deleted (in edit mode) — their
  /// transactions are soft-deleted alongside the wallet. Other wallet types
  /// can be deleted only when their book balance is 0.
  /// On deletion every income/expense record of the wallet is soft-deleted.
  Future<WalletDeleteOutcome> deleteWallet(String id) async {
    // Guard: cash and the last remaining bank account are mandatory.
    final index = wallets.indexWhere((w) => w.id == id);
    if (index == -1) return WalletDeleteOutcome.error;
    final wallet = wallets[index];

    if (!canDeleteWallet(wallet)) {
      return WalletDeleteOutcome.protected;
    }

    if (wallet.type == WalletType.investment) {
      // Investment wallets can always be deleted in edit mode, regardless of
      // contributed/returned activity — their transactions are soft-deleted
      // alongside the wallet below.
    } else {
      final balanceResult = await _getWalletBookBalance(id);
      if (balanceResult.isError()) {
        errorMessage.value = balanceResult.tryGetError()!.message;
        return WalletDeleteOutcome.error;
      }

      if (balanceResult.tryGetSuccess()!.abs() > 0) {
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
