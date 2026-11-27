import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../core/exchange_rates/currency_conversion_service.dart';
import '../repositories/transaction_repository.dart';
import 'reconciled_period_lock.dart';

/// The legs that make up one user-visible transaction.
///
/// A Chi ra (investment contribution) is stored as two legs sharing a
/// `transferId`: `investmentOut` on the liquid wallet (the cash balance) and
/// `investmentIn` on the position (contributed capital, ROI). Both must
/// always move together, so a delete or an edit of one applies to the pair.
/// Every other transaction is a single leg.
@injectable
class TransactionLegs {
  TransactionLegs(this._transactions, this._conversion, this._periodLock);

  final TransactionRepository _transactions;
  final CurrencyConversionService _conversion;
  final ReconciledPeriodLock _periodLock;

  static bool _isPaired(TransactionEntity t) =>
      (t.type == TransactionType.investmentOut ||
          t.type == TransactionType.investmentIn) &&
      (t.transferId?.isNotEmpty ?? false);

  /// [transaction] plus, for a Chi ra leg, its mirror leg.
  Future<List<TransactionEntity>> legsOf(TransactionEntity transaction) async {
    if (!_isPaired(transaction)) return [transaction];
    final all =
        (await _transactions.getListTransactions()).tryGetSuccess() ?? const [];
    final legs = all
        .where((t) => !t.hasDeleted && t.transferId == transaction.transferId)
        .toList();
    if (!legs.any((t) => t.id == transaction.id)) legs.add(transaction);
    return legs;
  }

  /// Whether any of [legs] is in a reconciled period (closed, immutable).
  Future<bool> hasReconciled(List<TransactionEntity> legs) async {
    final until = await _periodLock.lockedUntil();
    return legs.any((t) => ReconciledPeriodLock.hasLocked(t, until));
  }

  /// The mirror legs of [updated] rewritten to match it: same date, category
  /// and note, and the amount converted into each mirror leg's own currency.
  Future<Result<List<TransactionEntity>, CcFailure>> mirrorsFor(
    TransactionEntity updated,
  ) async {
    final mirrors = (await legsOf(
      updated,
    )).where((t) => t.id != updated.id).toList();
    final rewritten = <TransactionEntity>[];
    for (final mirror in mirrors) {
      var amount = updated.amount;
      if (mirror.currencyCode.toUpperCase() !=
          updated.currencyCode.toUpperCase()) {
        final converted = await _conversion.convertAmount(
          amount: updated.amount,
          fromCurrency: updated.currencyCode,
          toCurrency: mirror.currencyCode,
        );
        if (converted.isError()) return Error(converted.tryGetError()!);
        amount = converted.tryGetSuccess()!;
      }
      rewritten.add(
        TransactionEntity(
          id: mirror.id,
          type: mirror.type,
          amount: amount,
          category: updated.category,
          categoryId: updated.categoryId,
          categoryIconCode: updated.categoryIconCode,
          categoryIconFamily: updated.categoryIconFamily,
          note: updated.note,
          date: updated.date,
          walletId: mirror.walletId,
          transferId: mirror.transferId,
          investmentWalletId: mirror.investmentWalletId,
          liabilityId: mirror.liabilityId,
          currencyCode: mirror.currencyCode,
        ),
      );
    }
    return Success(rewritten);
  }

  /// Logs [legs] with their reconciled state under [tag].
  Future<void> trace(String tag, List<TransactionEntity> legs) async {
    final until = await _periodLock.lockedUntil();
    '[$tag] ${legs.length} leg(s), latest reconciliation: ${until ?? 'none'}'
        .Log(tag);
    for (final t in legs) {
      final state = ReconciledPeriodLock.hasLocked(t, until)
          ? 'RECONCILED'
          : 'open';
      '[$tag]   ${t.id} ${t.type} amount=${t.amount} wallet=${t.walletId} '
              'position=${t.investmentWalletId ?? '-'} '
              'date=${t.date.toIso8601String()} $state'
          .Log(tag);
    }
  }
}
