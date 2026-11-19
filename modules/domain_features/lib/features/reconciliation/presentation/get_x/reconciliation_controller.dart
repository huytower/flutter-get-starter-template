import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constant/currency_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../profile/user_level/presentation/get_x/user_level_controller.dart';
import '../../../wallet/domain/entities/wallet_balance_entity.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/usecases/get_wallet_balances_usecase.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../domain/entities/reconciliation_entity.dart';
import '../../domain/usecases/get_reconciliation_history_usecase.dart';
import '../../domain/usecases/perform_reconciliation_usecase.dart';
import '../../domain/usecases/undo_reconciliation_usecase.dart';
import '../widgets/reconciliation_success_sheet.dart';

@injectable
class ReconciliationController extends CcGetController {
  ReconciliationController(
    this._getWalletBalances,
    this._performReconciliation,
    this._undoReconciliation,
    this._getHistory,
    this._userLevel,
  );

  final GetWalletBalancesUseCase _getWalletBalances;
  final PerformReconciliationUseCase _performReconciliation;
  final UndoReconciliationUseCase _undoReconciliation;
  final GetReconciliationHistoryUseCase _getHistory;
  final UserLevelController _userLevel;

  final RxList<WalletBalanceEntity> balances = <WalletBalanceEntity>[].obs;
  final RxList<ReconciliationEntity> history = <ReconciliationEntity>[].obs;

  /// Counted balance per wallet id (defaults to the book balance).
  final RxMap<String, int> _actuals = <String, int>{}.obs;

  /// Wallet ids where the user explicitly acknowledged creating an adjustment.
  final RxSet<String> _acknowledged = <String>{}.obs;

  /// Unconverted balances (each in its wallet's own currency), keyed by wallet
  /// id. [balances] is converted to the display currency for the UI, but the
  /// reconciliation itself must compare and adjust in the wallet's currency.
  final Map<String, WalletBalanceEntity> _originals = {};

  final RxInt systemTotal = 0.obs;
  final RxInt actualTotal = 0.obs;
  final RxInt unhandledCount = 0.obs;
  final RxBool isSubmitting = false.obs;

  final RxnString editingWalletId = RxnString();
  final RxString amountStr = '0'.obs;

  String get currencyCode {
    if (Get.isRegistered<WalletController>()) {
      return Get.find<WalletController>().currencyCode.value;
    }
    return CurrencyConstants.defaultCurrencyCode;
  }

  int get difference => actualTotal.value - systemTotal.value;

  /// Reconciliation is only permitted when there is wallet activity, at
  /// least one wallet has been counted, no difference is left unacknowledged,
  /// and nothing is being submitted. Uncounted wallets are taken as matching
  /// their book balance.
  bool get canReconcile {
    final hasAmount = systemTotal.value > 0 || actualTotal.value > 0;
    return hasAmount &&
        _actuals.isNotEmpty &&
        unhandledCount.value == 0 &&
        balances.isNotEmpty &&
        !isSubmitting.value;
  }

  bool isAcknowledged(String walletId) => _acknowledged.contains(walletId);

  /// The counted amount, or null while the wallet has not been counted yet.
  int? actualOf(String walletId) => _actuals[walletId];

  void acknowledgeAdjustment(String walletId) {
    _acknowledged.add(walletId);
    _updateUnhandledCount();
  }

  void _updateUnhandledCount() {
    unhandledCount.value = balances.where((b) {
      final actual = _actuals[b.wallet.id] ?? b.bookBalance;
      return (actual - b.bookBalance) != 0 &&
          !_acknowledged.contains(b.wallet.id);
    }).length;
  }

  /// Actual total with uncounted wallets taken at their book balance.
  void _recomputeActualTotal() {
    actualTotal.value = balances.fold(
      0,
      (sum, b) => sum + (_actuals[b.wallet.id] ?? b.bookBalance),
    );
  }

  @override
  void onInit() {
    super.onInit();
    ever(CurrencyConstants.onCurrencyChanged, (_) => loadBalances());

    // This controller is permanent (it outlives the page), and onReady only
    // runs once, so wallets added / edited / removed later would never reach
    // the tiles. Follow the wallet list so it always matches the Wallets page.
    final walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(getIt<WalletController>());
    debounce(
      walletController.wallets,
      (_) => loadBalances(showLoading: false),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onReady() {
    super.onReady();
    loadBalances();
    loadHistory();
  }

  /// Bumped on every load so a slower, older load (e.g. one started by a
  /// currency change) can never overwrite the result of a newer one.
  int _loadSeq = 0;

  Future<void> loadBalances({bool showLoading = true}) async {
    final seq = ++_loadSeq;
    if (showLoading) layoutStatus.value = CcLayoutStatus.loading;
    final result = await _getWalletBalances.call();
    if (seq != _loadSeq) return;

    final error = result.tryGetError();
    if (error != null) {
      errorMessage.value = error.message;
      layoutStatus.value = CcLayoutStatus.error;
      return;
    }

    final walletController = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(getIt<WalletController>());
    final targetCurrency = walletController.currencyCode.value;

    // Investment positions are excluded — "Thu vào" now credits a real
    // liquid wallet directly, so an investment wallet's own balance is
    // just cumulative contributed capital, nothing real to count here.
    // The Emergency Fund stays reconciled normally, like cash/bank.
    final liquid = result
        .tryGetSuccess()!
        .where((b) => b.wallet.type != WalletType.investment)
        .toList();

    final convertedLiquid = <WalletBalanceEntity>[];
    for (final b in liquid) {
      final convResult = await walletController.conversionService.convertAmount(
        amount: b.bookBalance,
        fromCurrency: b.wallet.currencyCode,
        toCurrency: targetCurrency,
      );
      convertedLiquid.add(
        b.copyWith(bookBalance: convResult.tryGetSuccess() ?? b.bookBalance),
      );
    }
    if (seq != _loadSeq) return;

    _originals
      ..clear()
      ..addEntries(liquid.map((b) => MapEntry(b.wallet.id, b)));
    balances.assignAll(convertedLiquid);
    // Every wallet starts "not counted" (absent from the map).
    _actuals.clear();
    _acknowledged.clear();
    editingWalletId.value = null;
    systemTotal.value = convertedLiquid.fold(
      0,
      (sum, b) => sum + b.bookBalance,
    );
    _recomputeActualTotal();
    _updateUnhandledCount();
    layoutStatus.value = convertedLiquid.isEmpty
        ? CcLayoutStatus.empty
        : CcLayoutStatus.success;
  }

  Future<void> loadHistory() async {
    final result = await _getHistory.call();
    result.when((success) => history.assignAll(success), (_) {});
  }

  void setActual(String walletId, int value) {
    // An acknowledgement covers the difference the user saw; a new amount
    // means a new difference that has to be reviewed again.
    if (_actuals[walletId] != value) _acknowledged.remove(walletId);
    _actuals[walletId] = value;
    _recomputeActualTotal();
    _updateUnhandledCount();
  }

  /// Puts a wallet back to "not counted".
  void resetActual(String walletId) {
    _actuals.remove(walletId);
    _acknowledged.remove(walletId);
    if (editingWalletId.value == walletId) editingWalletId.value = null;
    _recomputeActualTotal();
    _updateUnhandledCount();
  }

  void startEditing(String walletId) {
    editingWalletId.value = walletId;
    amountStr.value = (_actuals[walletId] ?? 0).toString();
  }

  void stopEditing() {
    editingWalletId.value = null;
  }

  void updateAmount(String key) {
    if (amountStr.value == '0') {
      if (key != '0' && key != '000') {
        amountStr.value = key;
      }
    } else {
      amountStr.value += key;
    }
    _syncActual();
  }

  void deleteChar() {
    if (amountStr.value.length > 1) {
      amountStr.value = amountStr.value.substring(
        0,
        amountStr.value.length - 1,
      );
    } else {
      amountStr.value = '0';
    }
    _syncActual();
  }

  void clearAmount() {
    amountStr.value = '0';
    _syncActual();
  }

  void setAmount(int value) {
    amountStr.value = value.toString();
    _syncActual();
  }

  void _syncActual() {
    if (editingWalletId.value != null) {
      setActual(editingWalletId.value!, int.tryParse(amountStr.value) ?? 0);
    }
  }

  Future<void> confirmReconciliation(BuildContext context) async {
    final error = await performReconciliation();
    if (!context.mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ReconciliationSuccessSheet(
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  /// Returns null on success, or an error message to surface.
  Future<String?> performReconciliation() async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;
    try {
      final result = await _performReconciliation.call(
        await _actualsInWalletCurrency(),
        displayTotals: (
          systemTotal: systemTotal.value,
          actualTotal: actualTotal.value,
          currencyCode: currencyCode,
        ),
      );
      return result.when<String?>((_) {
        loadBalances(showLoading: false);
        loadHistory();
        _userLevel.refresh();
        return null;
      }, (error) => error.message);
    } finally {
      isSubmitting.value = false;
    }
  }

  /// The use case compares each actual with the wallet's book balance in the
  /// wallet's own currency, while the user typed amounts in the display
  /// currency. Convert them back; an amount equal to the (converted) book
  /// balance maps to the exact original book so a round-trip rounding error
  /// can never create a spurious adjustment.
  Future<Map<String, int>> _actualsInWalletCurrency() async {
    final targetCurrency = currencyCode;
    final converter = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>().conversionService
        : null;
    final result = <String, int>{};
    for (final shown in balances) {
      final id = shown.wallet.id;
      final original = _originals[id];
      final actual = _actuals[id];
      // Uncounted wallets are left out: the use case treats them as matching.
      if (actual == null) continue;
      if (original == null) {
        result[id] = actual;
        continue;
      }
      final walletCurrency = original.wallet.currencyCode;
      if (actual == shown.bookBalance) {
        result[id] = original.bookBalance;
      } else if (converter == null ||
          walletCurrency.toUpperCase() == targetCurrency.toUpperCase()) {
        result[id] = actual;
      } else {
        final converted = await converter.convertAmount(
          amount: actual,
          fromCurrency: targetCurrency,
          toCurrency: walletCurrency,
        );
        result[id] = converted.tryGetSuccess() ?? actual;
      }
    }
    return result;
  }

  Future<String?> undoLast() async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;
    try {
      final result = await _undoReconciliation.call();
      return result.when<String?>((_) {
        loadBalances(showLoading: false);
        loadHistory();
        _userLevel.refresh();
        return null;
      }, (error) => error.message);
    } finally {
      isSubmitting.value = false;
    }
  }
}
