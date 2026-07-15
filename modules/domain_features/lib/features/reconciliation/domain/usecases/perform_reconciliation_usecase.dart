import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../wallet/domain/usecases/get_wallet_balances_usecase.dart';
import '../entities/reconciliation_allocation_entity.dart';
import '../entities/reconciliation_entity.dart';
import '../reconciliation_period_utils.dart';
import '../repositories/reconciliation_repository.dart';

/// Performs a reconciliation (mirrors `KiemToanBCTCUseCase` +
/// `KiemToanRepo.luuKiemToan`):
///
/// 1. Snapshot each wallet's book balance.
/// 2. Compare against the user-entered actual balance.
/// 3. For each discrepancy, create an adjustment transaction (income for a
///    surplus / "dôi dư", expense for a shortfall / "hao hụt") so book = reality.
/// 4. Save the reconciliation record with the created adjustment ids.
@lazySingleton
class PerformReconciliationUseCase {
  PerformReconciliationUseCase(
    this._getWalletBalances,
    this._transactionRepository,
    this._reconciliationRepository,
  );

  final GetWalletBalancesUseCase _getWalletBalances;
  final TransactionRepository _transactionRepository;
  final ReconciliationRepository _reconciliationRepository;

  /// [actualByWalletId] maps a wallet id to the counted balance. Wallets absent
  /// from the map are assumed to match their book balance.
  Future<Result<ReconciliationEntity, CcFailure>> call(
    Map<String, int> actualByWalletId,
  ) async {
    final balancesResult = await _getWalletBalances.call();
    if (balancesResult.isError()) {
      return Error(balancesResult.tryGetError()!);
    }
    final balances = balancesResult.tryGetSuccess()!;

    final now = DateTime.now();
    final stamp = now.microsecondsSinceEpoch;
    final period = isoWeekOf(now);
    final allocations = <ReconciliationAllocationEntity>[];
    final adjustmentIds = <String>[];
    var systemTotal = 0;
    var actualTotal = 0;

    for (final balance in balances) {
      final book = balance.bookBalance;
      final actual = actualByWalletId[balance.wallet.id] ?? book;
      systemTotal += book;
      actualTotal += actual;

      allocations.add(
        ReconciliationAllocationEntity(
          walletId: balance.wallet.id,
          walletName: balance.wallet.name,
          bookBalance: book,
          actualBalance: actual,
        ),
      );

      final diff = actual - book;
      if (diff != 0) {
        final isSurplus = diff > 0;
        final adjustment = TransactionEntity(
          id: '${stamp}_${balance.wallet.id}',
          type: isSurplus ? 'income' : 'expense',
          amount: diff.abs(),
          category: 'Điều chỉnh khớp sổ',
          note: isSurplus
              ? 'Khớp sổ - Điều chỉnh dôi dư'
              : 'Khớp sổ - Điều chỉnh hao hụt',
          date: now,
          walletId: balance.wallet.id,
        );
        final created =
            await _transactionRepository.createTransaction(adjustment);
        if (created.isError()) {
          // Compensating rollback: undo the adjustments already created so we
          // don't leave orphaned "khớp sổ" transactions.
          await _rollback(adjustmentIds);
          return Error(created.tryGetError()!);
        }
        adjustmentIds.add(adjustment.id);
      }
    }

    final reconciliation = ReconciliationEntity(
      id: stamp.toString(),
      year: period.yearly,
      week: period.week,
      systemTotal: systemTotal,
      actualTotal: actualTotal,
      difference: actualTotal - systemTotal,
      allocations: allocations,
      adjustmentTransactionIds: adjustmentIds,
      date: now,
    );

    final saved =
        await _reconciliationRepository.saveReconciliation(reconciliation);
    if (saved.isError()) {
      await _rollback(adjustmentIds);
      return Error(saved.tryGetError()!);
    }
    return Success(reconciliation);
  }

  /// Best-effort deletion of adjustment transactions created during a failed
  /// reconciliation.
  Future<void> _rollback(List<String> adjustmentIds) async {
    for (final id in adjustmentIds) {
      await _transactionRepository.deleteTransaction(id);
    }
  }
}
