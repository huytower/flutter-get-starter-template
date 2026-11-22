import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/currency/book_currency_aligner.dart';
import 'package:domain_features/core/currency/record_currency_rebaser.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_failure.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_repository.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_result.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_table.dart';
import 'package:domain_features/core/exchange_rates/rate_provenance.dart';
import 'package:domain_features/features/budget_limit/domain/entities/budget_limit_entity.dart';
import 'package:domain_features/features/budget_limit/domain/repositories/budget_limit_repository.dart';
import 'package:domain_features/features/liability/domain/repositories/liability_repository.dart';
import 'package:domain_features/features/reconciliation/domain/entities/reconciliation_entity.dart';
import 'package:domain_features/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/services/wallet_ledger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

// The app shows every amount in the user's primary currency; arithmetic must
// be exact in it. Rate used by the app for VND: 1 USD = 25,982.5 đ.

const double _vndPerUsd = 25982.5;
final _epoch = DateTime.utc(2026);

class _Rates implements ExchangeRateRepository {
  bool available = true;

  @override
  Future<Result<ExchangeRateResult, ExchangeRateFailure>> getExchangeRates({
    required String baseCurrency,
    required List<String> quoteCurrencies,
    DateTime? date,
  }) async {
    if (!available) return const Error(ValidationExchangeRateFailure('none'));
    final rate = baseCurrency == 'USD' ? _vndPerUsd : 1 / _vndPerUsd;
    return Success(
      ExchangeRateResult(
        table: ExchangeRateTable(
          baseCurrency: baseCurrency,
          rates: {quoteCurrencies.single: rate},
          effectiveDate: _epoch,
          fetchedAt: DateTime.now(),
          provider: 'test',
        ),
        provenance: RateProvenance.network,
      ),
    );
  }
}

class _Wallets implements WalletRepository {
  final Map<String, WalletEntity> store = {};

  @override
  Future<Result<List<WalletEntity>, CcFailure>> getWallets() async =>
      Success(store.values.toList());

  @override
  Future<Result<void, CcFailure>> updateWallet(WalletEntity wallet) async {
    store[wallet.id] = wallet;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  final Map<String, TransactionEntity> store = {};
  int writes = 0;

  @override
  Future<Result<List<TransactionEntity>, CcFailure>>
  getListTransactions() async => Success(store.values.toList());

  @override
  Future<Result<void, CcFailure>> updateTransaction(TransactionEntity t) async {
    writes++;
    store[t.id] = t;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Liabilities implements LiabilityRepository {
  final Map<String, LiabilityEntity> store = {};

  @override
  Future<Result<List<LiabilityEntity>, CcFailure>> getLiabilities() async =>
      Success(store.values.toList());

  @override
  Future<Result<void, CcFailure>> updateLiability(LiabilityEntity l) async {
    store[l.id] = l;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Budgets implements BudgetLimitRepository {
  final Map<String, BudgetLimitEntity> store = {};

  @override
  Future<Result<List<BudgetLimitEntity>, CcFailure>> getBudgets({
    bool activeOnly = true,
  }) async => Success(store.values.toList());

  @override
  Future<Result<void, CcFailure>> updateBudget(BudgetLimitEntity b) async {
    store[b.id] = b;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Reconciliations implements ReconciliationRepository {
  @override
  Future<Result<List<ReconciliationEntity>, CcFailure>>
  getReconciliations() async => const Success([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletEntity _wallet(String id, int balance, String currency) => WalletEntity(
  id: id,
  name: id,
  balance: balance,
  iconCode: 0,
  type: WalletType.bank,
  createdAt: _epoch,
  updatedAt: _epoch,
  currencyCode: currency,
);

TransactionEntity _txn(
  String id,
  String type,
  int amount,
  String walletId,
  String currency,
) => TransactionEntity(
  id: id,
  type: type,
  amount: amount,
  category: '',
  date: _epoch,
  walletId: walletId,
  currencyCode: currency,
);

void main() {
  late _Rates rates;
  late _Wallets wallets;
  late _Transactions txns;
  late _Liabilities liabilities;
  late _Budgets budgets;
  late CurrencyConversionService conversion;
  late WalletLedger ledger;
  late BookCurrencyAligner aligner;

  setUp(() {
    rates = _Rates();
    wallets = _Wallets();
    txns = _Transactions();
    liabilities = _Liabilities();
    budgets = _Budgets();
    conversion = CurrencyConversionService(rates);
    ledger = WalletLedger(txns, conversion);
    aligner = BookCurrencyAligner(
      wallets,
      txns,
      ledger,
      conversion,
      RecordCurrencyRebaser(
        liabilities,
        budgets,
        _Reconciliations(),
        conversion,
      ),
    );
  });

  /// What the wallet screens show for [id], in [currency].
  Future<int> shown(String id, String currency) async {
    final list = wallets.store.values.toList();
    final snapshot = await ledger.build(list, currency);
    final display = await ledger.displayBalances(
      list,
      (w) => snapshot.bookBalances[w] ?? 0,
      currency,
    );
    return display[id]!;
  }

  test('VND book: 1,000,000 đ − 100,000 đ = 900,000 đ', () async {
    wallets.store['cash'] = _wallet('cash', 1000000, 'VND');
    txns.store['t'] = _txn('t', TransactionType.expense, 100000, 'cash', 'VND');

    expect(await shown('cash', 'VND'), 900000);
  });

  test(r'USD book: 100 $ − 10 $ = 90 $', () async {
    wallets.store['cash'] = _wallet('cash', 100, 'USD');
    txns.store['t'] = _txn('t', TransactionType.expense, 10, 'cash', 'USD');

    expect(await shown('cash', 'USD'), 90);
  });

  test('a USD wallet shown in VND is converted once, balance kept to the đ, '
      'then 100,000 đ takes exactly 100,000 đ', () async {
    // The reported case: wallets created in USD, app showing VND.
    wallets.store['bank'] = _wallet('bank', 474, 'USD');
    txns.store['t1'] = _txn('t1', TransactionType.income, 7, 'bank', 'USD');
    txns.store['t2'] = _txn('t2', TransactionType.expense, 4, 'bank', 'USD');
    final before = await shown('bank', 'VND');

    final result = await aligner.alignTo('VND');

    expect(result.tryGetSuccess(), isTrue);
    expect(wallets.store['bank']!.currencyCode, 'VND');
    expect(txns.store.values.every((t) => t.currencyCode == 'VND'), isTrue);
    expect(await shown('bank', 'VND'), before, reason: 'nothing jumps');

    txns.store['t3'] = _txn(
      't3',
      TransactionType.expense,
      100000,
      'bank',
      'VND',
    );
    expect(await shown('bank', 'VND'), before - 100000);
  });

  test(
    'switching the primary currency to USD converts the VND book once',
    () async {
      wallets.store['cash'] = _wallet('cash', 2598250, 'VND');
      txns.store['t'] = _txn(
        't',
        TransactionType.expense,
        259825,
        'cash',
        'VND',
      );

      await aligner.alignTo('USD');

      expect(wallets.store['cash']!.currencyCode, 'USD');
      expect(await shown('cash', 'USD'), 90);
      txns.store['t2'] = _txn('t2', TransactionType.expense, 10, 'cash', 'USD');
      expect(await shown('cash', 'USD'), 80);
    },
  );

  test('an aligned book is left alone', () async {
    wallets.store['cash'] = _wallet('cash', 1000000, 'VND');
    txns.store['t'] = _txn('t', TransactionType.expense, 100000, 'cash', 'VND');

    final result = await aligner.alignTo('VND');

    expect(result.tryGetSuccess(), isFalse);
    expect(txns.writes, 0);
    expect(wallets.store['cash']!.balance, 1000000);
  });

  test('no rate: nothing is written', () async {
    wallets.store['bank'] = _wallet('bank', 474, 'USD');
    txns.store['t'] = _txn('t', TransactionType.expense, 4, 'bank', 'USD');
    rates.available = false;

    final result = await aligner.alignTo('VND');

    expect(result.isError(), isTrue);
    expect(wallets.store['bank']!.currencyCode, 'USD');
    expect(txns.writes, 0);
  });

  test('liabilities and budgets move to the primary currency too', () async {
    liabilities.store['loan'] = LiabilityEntity(
      id: 'loan',
      direction: LiabilityDirection.lend,
      principalAmount: 40,
      categoryId: 'c',
      categoryLabel: 'Loan',
      walletId: 'bank',
      repaymentMethod: LiabilityRepaymentMethod.installment,
      installments: [LiabilityInstallmentEntity(dueDate: _epoch, amount: 20)],
      createdAt: _epoch,
      updatedAt: _epoch,
      currencyCode: 'USD',
    );
    budgets.store['food'] = const BudgetLimitEntity(
      id: 'food',
      categoryId: 'c',
      name: 'Food',
      limit: 100,
      order: 0,
      currencyCode: 'USD',
    );

    await aligner.alignTo('VND');

    final loan = liabilities.store['loan']!;
    expect(loan.currencyCode, 'VND');
    expect(loan.principalAmount, (40 * _vndPerUsd).round());
    expect(loan.installments!.single.amount, (20 * _vndPerUsd).round());
    expect(budgets.store['food']!.limit, (100 * _vndPerUsd).round());
    expect(budgets.store['food']!.currencyCode, 'VND');
  });
}
