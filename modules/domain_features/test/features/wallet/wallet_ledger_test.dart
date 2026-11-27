import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_repository.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/wallet/domain/entities/wallet_totals.dart';
import 'package:domain_features/features/wallet/domain/services/wallet_ledger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../support/no_reconciliations.dart';

class _FakeTransactions implements TransactionRepository {
  _FakeTransactions(this.transactions);

  final List<TransactionEntity> transactions;
  final List<String> softDeleted = [];

  @override
  Future<Result<List<TransactionEntity>, CcFailure>>
  getListTransactions() async => Success(transactions);

  @override
  Future<Result<void, CcFailure>> softDeleteByWallet(String walletId) async {
    softDeleted.add(walletId);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Every test uses one currency, so no rate is ever looked up.
class _NoRates implements ExchangeRateRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _epoch = DateTime.utc(2026);

WalletEntity _wallet(String id, String type, {int balance = 0}) => WalletEntity(
  id: id,
  name: id,
  balance: balance,
  iconCode: 0,
  type: type,
  createdAt: _epoch,
  updatedAt: _epoch,
);

TransactionEntity _txn(
  String type,
  int amount, {
  String walletId = 'cash',
  String? investmentWalletId,
  DateTime? date,
}) => TransactionEntity(
  id: '$type-$amount-$walletId',
  type: type,
  amount: amount,
  category: '',
  date: date ?? DateTime.now(),
  walletId: walletId,
  investmentWalletId: investmentWalletId,
);

WalletLedger _ledger(List<TransactionEntity> txns) => WalletLedger(
  _FakeTransactions(txns),
  CurrencyConversionService(_NoRates()),
  noReconciliationLock(),
);

void main() {
  group('WalletLedger.build', () {
    test(
      'book balance is the opening balance plus inflows minus outflows',
      () async {
        final snapshot = await _ledger([
          _txn(TransactionType.income, 500),
          _txn(TransactionType.expense, 200),
          _txn(TransactionType.transferIn, 50),
          _txn(TransactionType.transferOut, 30),
          // A legacy type moves no money.
          // ignore: deprecated_member_use_from_same_package
          _txn(TransactionType.debtLoan, 999),
        ]).build([_wallet('cash', WalletType.cash, balance: 100)], 'USD');

        expect(snapshot.bookBalances['cash'], 100 + 500 - 200 + 50 - 30);
        expect(snapshot.walletsWithTransactions, {'cash'});
      },
    );

    test('investment stats split all-time from this month', () async {
      final lastYear = DateTime.now().subtract(const Duration(days: 400));
      final snapshot = await _ledger([
        _txn(
          TransactionType.investmentIn,
          300,
          walletId: 'fund',
          investmentWalletId: 'fund',
        ),
        _txn(
          TransactionType.investmentIn,
          200,
          walletId: 'fund',
          investmentWalletId: 'fund',
          date: lastYear,
        ),
        _txn(
          TransactionType.investmentReturn,
          80,
          walletId: 'fund',
          investmentWalletId: 'fund',
        ),
      ]).build([_wallet('fund', WalletType.investment)], 'USD');

      expect(snapshot.investmentStats['fund'], (
        contributed: 500,
        returned: 80,
      ));
      expect(snapshot.monthlyInvestmentStats['fund'], (
        contributed: 300,
        returned: 80,
      ));
    });

    test(
      'an investment wallet with no contribution counts its opening balance',
      () async {
        final snapshot = await _ledger(
          const [],
        ).build([_wallet('fund', WalletType.investment, balance: 700)], 'USD');

        expect(snapshot.investmentStats['fund'], (
          contributed: 700,
          returned: 0,
        ));
      },
    );
  });

  test('removeTransactionsOf soft-deletes the wallet transactions', () async {
    final transactions = _FakeTransactions(const []);
    final ledger = WalletLedger(
      transactions,
      CurrencyConversionService(_NoRates()),
      noReconciliationLock(),
    );

    await ledger.removeTransactionsOf('bank');

    expect(transactions.softDeleted, ['bank']);
  });

  group('removeTransactionsOf after a reconciliation (BR §4.B)', () {
    final reconciledAt = DateTime(2026, 11, 15, 20);
    final before = DateTime(2026, 11, 5);
    final after = DateTime(2026, 11, 20);

    // One position: Chi ra (out-leg on cash + in-leg on the position) and a
    // Thu vào paid into cash.
    List<TransactionEntity> position({required DateTime date}) => [
      _txn(
        TransactionType.investmentOut,
        6000,
        walletId: 'cash',
        investmentWalletId: 'stock',
        date: date,
      ),
      // The in-leg is a copy of the out-leg, so it carries investmentWalletId.
      _txn(
        TransactionType.investmentIn,
        6000,
        walletId: 'stock',
        investmentWalletId: 'stock',
        date: date,
      ),
      _txn(
        TransactionType.investmentReturn,
        500,
        walletId: 'cash',
        investmentWalletId: 'stock',
        date: date,
      ),
    ];

    test('refuses, deleting nothing, when a leg is reconciled', () async {
      final transactions = _FakeTransactions(position(date: before));
      final ledger = WalletLedger(
        transactions,
        CurrencyConversionService(_NoRates()),
        reconciliationLockAt(reconciledAt),
      );

      final result = await ledger.removeTransactionsOf('stock');

      expect(
        result.tryGetError()?.message,
        PrjLocaleKeys.wallet_delete_error_reconciled,
      );
      expect(transactions.softDeleted, isEmpty);
    });

    test('deletes when every leg is after the reconciliation', () async {
      final transactions = _FakeTransactions(position(date: after));
      final ledger = WalletLedger(
        transactions,
        CurrencyConversionService(_NoRates()),
        reconciliationLockAt(reconciledAt),
      );

      final result = await ledger.removeTransactionsOf('stock');

      expect(result.isSuccess(), isTrue);
      expect(transactions.softDeleted, ['stock']);
    });

    test(
      'an allowed delete gives the money back to cash and clears ROI',
      () async {
        final wallets = [
          _wallet('cash', WalletType.cash, balance: 10000),
          _wallet('stock', WalletType.investment),
        ];

        final withPosition = await _ledger(
          position(date: after),
        ).build(wallets, 'USD');
        // The repository no longer returns soft-deleted transactions.
        final afterDelete = await _ledger(const []).build(wallets, 'USD');

        expect(withPosition.bookBalances['cash'], 10000 - 6000 + 500);
        expect(withPosition.investmentStats['stock']?.contributed, 6000);
        expect(
          afterDelete.bookBalances['cash'],
          10000,
          reason: 'Chi ra refunded',
        );
        expect(afterDelete.investmentStats['stock']?.contributed ?? 0, 0);
        expect(afterDelete.investmentStats['stock']?.returned ?? 0, 0);
      },
    );
  });

  test('WalletTotals sums by type and computes ROI', () {
    final wallets = [
      _wallet('cash', WalletType.cash),
      _wallet('bank', WalletType.bank),
      _wallet('rainy', WalletType.emergencyFund),
      _wallet('fund', WalletType.investment),
    ];
    const balances = {'cash': 100, 'bank': 200, 'rainy': 50, 'fund': 0};

    final totals = WalletTotals.of(
      wallets,
      displayBalanceOf: (id) => balances[id]!,
      statsOf: (id) => id == 'fund'
          ? (contributed: 400, returned: 500)
          : (contributed: 0, returned: 0),
      monthlyStatsOf: (_) => (contributed: 0, returned: 0),
    );

    expect(totals.total, 350);
    expect(totals.liquid, 300);
    expect(totals.emergencyFund, 50);
    expect(totals.allTimeInvested, 400);
    expect(totals.roiPercent, 25);
    expect(totals.breakevenPercent, 125);
    expect(totals.monthlyRoiPercent, 0);
  });
}
