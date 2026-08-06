import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../../core/getx/guideline_controller.dart';
import '../../../reconciliation/presentation/get_x/reconciliation_controller.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/presentation/get_x/transaction_controller.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/get_wallet_book_balance_usecase.dart';
import '../../domain/usecases/wallet_balance_calculator.dart';
import '../widgets/add_wallet_sheet.dart';
import '../widgets/wallet_delete_confirm_sheet.dart';

/// Outcome of a wallet deletion attempt (rule: only empty wallets deletable).
enum WalletDeleteOutcome { success, notEmpty, protected, error }

@lazySingleton
class WalletController extends CcGetController {
  WalletController(
    this._repository,
    this._transactionRepository,
    this._getWalletBookBalance,
  );

  final WalletRepository _repository;
  final TransactionRepository _transactionRepository;
  final GetWalletBookBalanceUseCase _getWalletBookBalance;

  final RxInt currentNavIndex = 1.obs;
  final RxBool isBalanceVisible = true.obs;

  /// When true, the wallet list shows edit/delete affordances on each item.
  final RxBool isEditMode = false.obs;

  void toggleEditMode() => isEditMode.toggle();

  void onCloseEditMode(BuildContext context) {
    isEditMode.value = false;
    Navigator.of(context).pop();
  }

  void openForm(BuildContext context, {WalletEntity? wallet}) {
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

  void confirmDelete(BuildContext context, WalletEntity wallet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => WalletDeleteConfirmSheet(
        wallet: wallet,
        onDelete: () => deleteWallet(wallet.id),
        onOutcome: (outcome) => _handleDeleteOutcome(context, outcome),
      ),
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
  final RxInt liabilityBalance = 0.obs;

  /// Ids of wallets that have at least one (non-deleted) transaction. Used to
  /// lock the opening balance once a wallet has activity.
  final Set<String> _walletsWithTxns = <String>{};

  bool walletHasTransactions(String id) => _walletsWithTxns.contains(id);

  /// Current (book) balance per wallet = opening balance ± transactions.
  /// This is what the UI shows, not [WalletEntity.balance] (the opening amount).
  final RxMap<String, int> _bookBalances = <String, int>{}.obs;

  int bookBalanceOf(String id) => _bookBalances[id] ?? 0;

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
    for (final wallet in list) {
      final walletTxns = txns.where((t) => t.walletId == wallet.id).toList();
      newBalances[wallet.id] = bookBalanceFromTransactions(
        wallet.balance,
        walletTxns,
      );
    }
    _bookBalances.assignAll(newBalances);
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

    investmentBalance.value = wallets
        .where((w) => w.type == WalletType.investment)
        .fold(0, (sum, item) => sum + bookBalanceOf(item.id));

    liabilityBalance.value = 0;
  }

  Future<void> addWallet({
    required String name,
    required int initialBalance,
    required int iconCode,
    required String type,
  }) async {
    final newWallet = WalletEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      balance: initialBalance,
      iconCode: iconCode,
      type: type,
      createdAt: DateTime.now(),
    );

    final result = await _repository.addWallet(newWallet);

    result.when(
      (success) {
        _bookBalances[newWallet.id] = newWallet.balance;
        wallets.add(newWallet);
        _calculateTotalBalance();
        layoutStatus.value = CcLayoutStatus.success;

        if (Get.isRegistered<TransactionController>()) {
          Get.find<TransactionController>().wallets.add(newWallet);
        }

        // Guideline: wallet_balance completed if initial balance > 0
        if (initialBalance > 0) {
          Get.find<GuidelineController>().completeTask('wallet_balance');
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

          // Guideline: wallet_balance completed if new balance > 0
          if (toSave.balance > 0) {
            Get.find<GuidelineController>().completeTask('wallet_balance');
          }
        }
      },
      (error) {
        errorMessage.value = error.message;
      },
    );
  }

  /// Rule 2: a wallet can be deleted only when its book balance is 0. On
  /// deletion every income/expense record of the wallet is soft-deleted.
  Future<WalletDeleteOutcome> deleteWallet(String id) async {
    // Guard: cash and the last remaining bank account are mandatory.
    final index = wallets.indexWhere((w) => w.id == id);
    if (index != -1 && !canDeleteWallet(wallets[index])) {
      return WalletDeleteOutcome.protected;
    }

    final balanceResult = await _getWalletBookBalance(id);
    if (balanceResult.isError()) {
      errorMessage.value = balanceResult.tryGetError()!.message;
      return WalletDeleteOutcome.error;
    }

    if (balanceResult.tryGetSuccess()!.abs() > 0) {
      return WalletDeleteOutcome.notEmpty;
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
