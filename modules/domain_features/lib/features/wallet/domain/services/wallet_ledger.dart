import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/domain/services/reconciled_period_lock.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import 'wallet_ledger_snapshot.dart';

export 'wallet_ledger_snapshot.dart';

/// Wallet ↔ transaction arithmetic: book balances, investment stats, display
/// balances in the user's currency, and removing a wallet's transactions.
@injectable
class WalletLedger {
  WalletLedger(this._transactions, this._conversion, this._periodLock);

  final TransactionRepository _transactions;
  final CurrencyConversionService _conversion;
  final ReconciledPeriodLock _periodLock;

  /// Exposed for screens that still convert amounts through the wallet
  /// controller; new code injects [CurrencyConversionService] directly.
  CurrencyConversionService get conversionService => _conversion;

  /// Reads every transaction once and derives the [WalletLedgerSnapshot] of
  /// [wallets]; stats are converted to [targetCurrency].
  Future<WalletLedgerSnapshot> build(
    List<WalletEntity> wallets,
    String targetCurrency,
  ) async {
    final result = await _transactions.getListTransactions();
    final txns = result.when((t) => t, (_) => <TransactionEntity>[]);

    final balances = <String, int>{};
    final stats = <String, InvestmentStats>{};
    final monthly = <String, InvestmentStats>{};
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    await Future.wait(
      wallets.map((wallet) async {
        balances[wallet.id] = await _bookBalance(wallet, txns);
        if (wallet.type != WalletType.investment) return;

        final investedIn = txns
            .where(
              (t) =>
                  t.investmentWalletId == wallet.id &&
                  t.type == TransactionType.investmentIn,
            )
            .toList();
        final returned = txns
            .where(
              (t) =>
                  t.investmentWalletId == wallet.id &&
                  t.type == TransactionType.investmentReturn,
            )
            .toList();
        bool thisMonth(TransactionEntity t) => t.date.isAfter(monthStart);

        var initialContributed = 0;
        if (investedIn.isEmpty && wallet.balance > 0) {
          final conv = await _conversion.convertAmount(
            amount: wallet.balance,
            fromCurrency: wallet.currencyCode,
            toCurrency: targetCurrency,
          );
          initialContributed = conv.tryGetSuccess() ?? wallet.balance;
        }

        final sums = await Future.wait([
          _sum(investedIn, targetCurrency),
          _sum(returned, targetCurrency),
          _sum(investedIn.where(thisMonth), targetCurrency),
          _sum(returned.where(thisMonth), targetCurrency),
        ]);
        stats[wallet.id] = (
          contributed: initialContributed + sums[0],
          returned: sums[1],
        );
        monthly[wallet.id] = (contributed: sums[2], returned: sums[3]);
      }),
    );

    return WalletLedgerSnapshot(
      walletsWithTransactions: {for (final t in txns) t.walletId},
      bookBalances: balances,
      investmentStats: stats,
      monthlyInvestmentStats: monthly,
    );
  }

  /// Each wallet's book balance ([bookBalanceOf]) converted to
  /// [targetCurrency].
  Future<Map<String, int>> displayBalances(
    List<WalletEntity> wallets,
    int Function(String walletId) bookBalanceOf,
    String targetCurrency,
  ) async {
    final entries = await Future.wait(
      wallets.map((wallet) async {
        final raw = bookBalanceOf(wallet.id);
        final result = await _conversion.convertAmount(
          amount: raw,
          fromCurrency: wallet.currencyCode,
          toCurrency: targetCurrency,
        );
        return MapEntry(wallet.id, result.tryGetSuccess() ?? raw);
      }),
    );
    return Map.fromEntries(entries);
  }

  /// Soft-deletes transactions of [walletId] in the open period.
  ///
  /// For an investment position that also means the legs living on a liquid
  /// wallet (Chi ra out-leg, Thu vào), matched by `investmentWalletId`.
  /// Deleting open legs gives the Chi ra money back to that liquid wallet,
  /// removes open Thu vào from it, and updates ROI accordingly.
  ///
  /// Transactions in a reconciled period ([ReconciledPeriodLock]) are preserved
  /// (not deleted) to protect closed historical balances.
  Future<Result<void, CcFailure>> removeTransactionsOf(String walletId) async {
    final lockedUntil = await _periodLock.lockedUntil();
    final all = (await _transactions.getListTransactions()).tryGetSuccess();
    final targets = (all ?? const <TransactionEntity>[])
        .where(
          (t) =>
              !t.hasDeleted &&
              (t.walletId == walletId || t.investmentWalletId == walletId),
        )
        .toList();

    final openTargets = targets
        .where((t) => !ReconciledPeriodLock.hasLocked(t, lockedUntil))
        .toList();

    if (openTargets.isNotEmpty) {
      final ids = openTargets.map((t) => t.id).toList();
      final result = await _transactions.softDeleteByIds(ids);
      if (result.isError()) return result;
    }

    return const Success(null);
  }


  /// Opening balance ± each transaction, converted to the wallet's currency.
  Future<int> _bookBalance(
    WalletEntity wallet,
    List<TransactionEntity> txns,
  ) async {
    final walletTxns = txns.where((t) => t.walletId == wallet.id).toList();
    final amounts = await Future.wait(
      walletTxns.map((txn) async {
        if (txn.currencyCode.toUpperCase() ==
            wallet.currencyCode.toUpperCase()) {
          return txn.amount;
        }
        final converted = await _conversion.convertAmount(
          amount: txn.amount,
          fromCurrency: txn.currencyCode,
          toCurrency: wallet.currencyCode,
        );
        return converted.tryGetSuccess() ?? txn.amount;
      }),
    );

    var balance = wallet.balance;
    for (var i = 0; i < walletTxns.length; i++) {
      balance += signOf(walletTxns[i].type) * amounts[i];
    }
    return balance;
  }

  /// Sum of [txns] converted to [targetCurrency].
  Future<int> _sum(
    Iterable<TransactionEntity> txns,
    String targetCurrency,
  ) async {
    final amounts = await Future.wait(
      txns.map((t) async {
        final conv = await _conversion.convertAmount(
          amount: t.amount,
          fromCurrency: t.currencyCode,
          toCurrency: targetCurrency,
        );
        return conv.tryGetSuccess() ?? t.amount;
      }),
    );
    return amounts.fold<int>(0, (sum, amount) => sum + amount);
  }

  /// +1 for money entering a wallet, -1 for money leaving it, 0 for any other
  /// (legacy) type.
  static int signOf(String type) => switch (type) {
    TransactionType.income ||
    TransactionType.transferIn ||
    TransactionType.investmentIn ||
    TransactionType.investmentReturn ||
    TransactionType.debtBorrow ||
    TransactionType.debtCollect => 1,
    TransactionType.expense ||
    TransactionType.transferOut ||
    TransactionType.investmentOut ||
    TransactionType.debtLend ||
    TransactionType.debtRepay => -1,
    _ => 0,
  };
}
