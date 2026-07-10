import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../../wallet/domain/entities/wallet_balance_entity.dart';
import '../../../wallet/domain/usecases/get_wallet_balances_usecase.dart';
import '../../domain/entities/reconciliation_entity.dart';
import '../../domain/usecases/get_reconciliation_history_usecase.dart';
import '../../domain/usecases/perform_reconciliation_usecase.dart';
import '../../domain/usecases/undo_reconciliation_usecase.dart';

class ReconciliationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => getIt<ReconciliationController>());
  }
}

@injectable
class ReconciliationController extends CcGetController {
  ReconciliationController(
    this._getWalletBalances,
    this._performReconciliation,
    this._undoReconciliation,
    this._getHistory,
  );

  final GetWalletBalancesUseCase _getWalletBalances;
  final PerformReconciliationUseCase _performReconciliation;
  final UndoReconciliationUseCase _undoReconciliation;
  final GetReconciliationHistoryUseCase _getHistory;

  final RxList<WalletBalanceEntity> balances = <WalletBalanceEntity>[].obs;
  final RxList<ReconciliationEntity> history = <ReconciliationEntity>[].obs;

  /// Counted balance per wallet id (defaults to the book balance).
  final Map<String, int> _actuals = {};

  /// Wallet ids where the user explicitly acknowledged creating an adjustment.
  final _acknowledged = <String>{};

  final RxInt systemTotal = 0.obs;
  final RxInt actualTotal = 0.obs;
  final RxInt unhandledCount = 0.obs;
  final RxBool isSubmitting = false.obs;

  int get difference => actualTotal.value - systemTotal.value;

  bool isAcknowledged(String walletId) => _acknowledged.contains(walletId);

  void acknowledgeAdjustment(String walletId) {
    _acknowledged.add(walletId);
    _updateUnhandledCount();
  }

  void _updateUnhandledCount() {
    unhandledCount.value = balances.where((b) {
      final actual = _actuals[b.wallet.id] ?? b.bookBalance;
      return (actual - b.bookBalance) != 0 && !_acknowledged.contains(b.wallet.id);
    }).length;
  }

  @override
  void onReady() {
    super.onReady();
    loadBalances();
    loadHistory();
  }

  Future<void> loadBalances() async {
    layoutStatus.value = CcLayoutStatus.loading;
    final result = await _getWalletBalances.call();
    result.when(
      (success) {
        balances.assignAll(success);
        _actuals
          ..clear()
          ..addEntries(success.map((b) => MapEntry(b.wallet.id, b.bookBalance)));
        _acknowledged.clear();
        systemTotal.value = success.fold(0, (sum, b) => sum + b.bookBalance);
        actualTotal.value = systemTotal.value;
        unhandledCount.value = 0;
        layoutStatus.value =
            success.isEmpty ? CcLayoutStatus.empty : CcLayoutStatus.success;
      },
      (error) {
        errorMessage.value = error.message;
        layoutStatus.value = CcLayoutStatus.error;
      },
    );
  }

  Future<void> loadHistory() async {
    final result = await _getHistory.call();
    result.when((success) => history.assignAll(success), (_) {});
  }

  void setActual(String walletId, int value) {
    _actuals[walletId] = value;
    actualTotal.value = _actuals.values.fold(0, (sum, v) => sum + v);
    _updateUnhandledCount();
  }

  /// Returns null on success, or an error message to surface.
  Future<String?> performReconciliation() async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;
    try {
      final result = await _performReconciliation.call(Map.of(_actuals));
      return result.when(
        (_) {
          loadBalances();
          loadHistory();
          return null;
        },
        (error) => error.message,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String?> undoLast() async {
    if (isSubmitting.value) return null;
    isSubmitting.value = true;
    try {
      final result = await _undoReconciliation.call();
      return result.when(
        (_) {
          loadBalances();
          loadHistory();
          return null;
        },
        (error) => error.message,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
