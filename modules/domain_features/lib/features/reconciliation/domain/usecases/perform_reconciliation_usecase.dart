import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:injectable/injectable.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

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

  /// [actualByWalletId] maps a wallet id to the counted balance, in that
  /// wallet's own currency. Wallets absent from the map are assumed to match
  /// their book balance.
  ///
  /// Wallets can hold different currencies, so their raw sums are not a
  /// meaningful total. Pass [displayTotals] (both totals already converted to
  /// one currency) to store totals the history can show; without it the raw
  /// sums are kept, which is only correct when every wallet shares a currency.
  Future<Result<ReconciliationEntity, CcFailure>> call(
    Map<String, int> actualByWalletId, {
    ({int systemTotal, int actualTotal, String currencyCode})? displayTotals,
  }) async {
    final balancesResult = await _getWalletBalances.call();
    if (balancesResult.isError()) {
      return Error(balancesResult.tryGetError()!);
    }
    // Investment positions are excluded: "Thu vào" now credits a real
    // liquid wallet directly (see CreateInvestmentTransactionUseCase), so an
    // investment wallet's own book balance is just cumulative contributed
    // capital (cost basis) — nothing real ever lands there to physically
    // count or mismatch. The Emergency Fund, by contrast, is a real
    // user-managed wallet like cash/bank and stays reconciled normally.
    final balances = balancesResult
        .tryGetSuccess()!
        .where((b) => b.wallet.type != WalletType.investment)
        .toList();

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
        final hasSurplus = diff > 0;
        final adjustment = TransactionEntity(
          id: '${stamp}_${balance.wallet.id}',
          type: hasSurplus ? TransactionType.income : TransactionType.expense,
          amount: diff.abs(),
          category: el.tr(PrjLocaleKeys.reconciliation_adjustment_category),
          note: el.tr(
            hasSurplus
                ? PrjLocaleKeys.reconciliation_adjustment_surplus
                : PrjLocaleKeys.reconciliation_adjustment_shortfall,
          ),
          date: now,
          walletId: balance.wallet.id,
          currencyCode: balance.wallet.currencyCode,
        );
        final created = await _transactionRepository.createTransaction(
          adjustment,
        );
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
      systemTotal: displayTotals?.systemTotal ?? systemTotal,
      actualTotal: displayTotals?.actualTotal ?? actualTotal,
      difference:
          (displayTotals?.actualTotal ?? actualTotal) -
          (displayTotals?.systemTotal ?? systemTotal),
      allocations: allocations,
      adjustmentTransactionIds: adjustmentIds,
      date: now,
      currencyCode:
          displayTotals?.currencyCode ??
          CurrencyConstants.currentPrimaryCurrency,
    );

    final saved = await _reconciliationRepository.saveReconciliation(
      reconciliation,
    );
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
