import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/currency/currency_rebase.dart';
import 'package:domain_features/core/currency/record_currency_rebaser.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/services/wallet_ledger.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

/// Keeps the whole book in the user's primary currency.
///
/// The app shows every amount in one primary currency (any supported one).
/// Records stored in another currency (e.g. wallets created in USD before the
/// app settled on VND) made each entry go through a conversion rounded to whole
/// units: 100,000 đ became 4 USD, shown back as 103,930 đ. Once every record
/// is in the primary currency, entries are added and subtracted as typed:
/// 1,000,000 đ − 100,000 đ = 900,000 đ, and 100 $ − 10 $ = 90 $.
///
/// [alignTo] converts once, keeping each wallet's balance exactly as it was
/// shown, and is all or nothing (a missing rate writes nothing).
@lazySingleton
class BookCurrencyAligner {
  BookCurrencyAligner(
    this._wallets,
    this._transactions,
    this._ledger,
    this._conversion,
    this._records,
  );

  final WalletRepository _wallets;
  final TransactionRepository _transactions;
  final WalletLedger _ledger;
  final CurrencyConversionService _conversion;
  final RecordCurrencyRebaser _records;

  /// Converts every record not in [target]; true when anything changed.
  Future<Result<bool, CcFailure>> alignTo(String target) async {
    final walletsResult = await _wallets.getWallets();
    if (walletsResult.isError()) return Error(walletsResult.tryGetError()!);
    final txnsResult = await _transactions.getListTransactions();
    if (txnsResult.isError()) return Error(txnsResult.tryGetError()!);
    final wallets = walletsResult.tryGetSuccess()!;
    final txns = txnsResult.tryGetSuccess()!;
    final rebase = CurrencyRebase(_conversion, target);

    final walletChanges = <WalletEntity>[];
    final txnChanges = <TransactionEntity>[];
    if (wallets.any((w) => rebase.needs(w.currencyCode)) ||
        txns.any((t) => rebase.needs(t.currencyCode))) {
      // What each wallet shows now, in the target currency: kept exactly.
      final snapshot = await _ledger.build(wallets, target);
      final shown = await _ledger.displayBalances(
        wallets,
        (id) => snapshot.bookBalances[id] ?? 0,
        target,
      );

      final aligned = <TransactionEntity>[];
      for (final t in txns) {
        if (!rebase.needs(t.currencyCode)) {
          aligned.add(t);
          continue;
        }
        final moved = t.copyWith(
          amount: await rebase.convert(t.amount, t.currencyCode),
          currencyCode: target,
        );
        aligned.add(moved);
        txnChanges.add(moved);
      }

      for (final w in wallets) {
        // Opening balance that gives back the shown balance with the
        // converted transactions: shown = opening + Σ signed amounts.
        final moves = aligned
            .where((t) => t.walletId == w.id)
            .fold<int>(
              0,
              (sum, t) => sum + WalletLedger.signOf(t.type) * t.amount,
            );
        final opening = (shown[w.id] ?? w.balance) - moves;
        if (rebase.needs(w.currencyCode) || opening != w.balance) {
          walletChanges.add(w.copyWith(balance: opening, currencyCode: target));
        }
      }
      if (rebase.failed) {
        return Error(ValidationFailure('No exchange rate into $target'));
      }
    }

    for (final t in txnChanges) {
      final saved = await _transactions.updateTransaction(t);
      if (saved.isError()) return Error(saved.tryGetError()!);
    }
    for (final w in walletChanges) {
      final saved = await _wallets.updateWallet(w);
      if (saved.isError()) return Error(saved.tryGetError()!);
    }

    final records = await _records.alignTo(target);
    if (records.isError()) return Error(records.tryGetError()!);

    return Success(
      walletChanges.isNotEmpty ||
          txnChanges.isNotEmpty ||
          records.tryGetSuccess()! > 0,
    );
  }
}
