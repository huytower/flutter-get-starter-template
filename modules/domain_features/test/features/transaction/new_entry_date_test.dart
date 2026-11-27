import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/conversion_use.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/features/transaction/domain/entities/investment_direction.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/transaction/domain/services/reconciled_period_lock.dart';
import 'package:domain_features/features/transaction/domain/usecases/create_investment_transaction_usecase.dart';
import 'package:domain_features/features/transaction/domain/usecases/create_transaction_usecase.dart';
import 'package:domain_features/features/transaction/domain/usecases/create_wallet_transfer_usecase.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../support/no_reconciliations.dart';

// Saved after today's reconciliation, with a form date taken before it: the
// entry is new, so it must stay editable.

final _today = DateTime.now();
final _formOpenedAt = DateTime(_today.year, _today.month, _today.day);
final _reconciledAt = _formOpenedAt.add(const Duration(microseconds: 1));

WalletEntity _wallet(String id, String type) => WalletEntity(
  id: id,
  name: id,
  balance: 0,
  iconCode: 0,
  type: type,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

class _Wallets implements WalletRepository {
  final store = {
    'cash': _wallet('cash', WalletType.cash),
    'bank': _wallet('bank', WalletType.bank),
    'stock': _wallet('stock', WalletType.investment),
  };

  @override
  Future<Result<WalletEntity, CcFailure>> getWallet(String id) async =>
      Success(store[id]!);

  @override
  Future<Result<void, CcFailure>> updateWallet(WalletEntity wallet) async =>
      const Success(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  final created = <TransactionEntity>[];

  @override
  Future<Result<void, CcFailure>> createTransaction(
    TransactionEntity transaction,
  ) async {
    created.add(transaction);
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Balance implements GetWalletBookBalanceUseCase {
  @override
  Future<Result<int, CcFailure>> call(String walletId) async =>
      const Success(1000000000);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SameCurrency implements CurrencyConversionService {
  @override
  Future<Result<int, CcFailure>> convertAmount({
    required num amount,
    required String fromCurrency,
    required String toCurrency,
    DateTime? date,
    ConversionUse use = ConversionUse.display,
  }) async => Success(amount.round());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Transactions transactions;
  final lock = reconciliationLockAt(_reconciledAt);

  setUp(() => transactions = _Transactions());

  Future<void> expectEditable(int count) async {
    expect(transactions.created, hasLength(count));
    final until = await lock.lockedUntil();
    for (final entry in transactions.created) {
      expect(
        ReconciledPeriodLock.hasLocked(entry, until),
        isFalse,
        reason: '${entry.type} dated ${entry.date} is locked',
      );
    }
  }

  CreateTransactionParams expense(DateTime date) => CreateTransactionParams(
    type: TransactionType.expense,
    amount: 200000,
    categoryId: 'water',
    walletId: 'cash',
    date: date,
  );

  CreateTransactionUseCase createExpense() => CreateTransactionUseCase(
    transactions,
    _Wallets(),
    _Balance(),
    _SameCurrency(),
  );

  test('an expense saved after the reconciliation is editable', () async {
    await createExpense()(expense(_formOpenedAt));

    await expectEditable(1);
  });

  test('both legs of an investment contribution are editable', () async {
    await CreateInvestmentTransactionUseCase(
      transactions,
      _Wallets(),
      _Balance(),
      _SameCurrency(),
    )(
      CreateInvestmentTransactionParams(
        direction: InvestmentDirection.contribute,
        liquidWalletId: 'cash',
        investmentWalletId: 'stock',
        categoryId: 'stock',
        categoryLabel: 'Stock',
        amount: 200000,
        date: _formOpenedAt,
      ),
    );

    await expectEditable(2);
  });

  test('an investment return is editable', () async {
    await CreateInvestmentTransactionUseCase(
      transactions,
      _Wallets(),
      _Balance(),
      _SameCurrency(),
    )(
      CreateInvestmentTransactionParams(
        direction: InvestmentDirection.returnProfit,
        liquidWalletId: 'cash',
        investmentWalletId: 'stock',
        categoryId: 'stock',
        categoryLabel: 'Stock',
        amount: 200000,
        date: _formOpenedAt,
      ),
    );

    await expectEditable(1);
  });

  test('both legs of a transfer are editable', () async {
    await CreateWalletTransferUseCase(
      transactions,
      _Wallets(),
      _Balance(),
      _SameCurrency(),
    )(
      CreateWalletTransferParams(
        sourceWalletId: 'cash',
        destinationWalletId: 'bank',
        amount: 100,
        categoryLabel: 'Transfer',
        date: _formOpenedAt,
      ),
    );

    await expectEditable(2);
  });

  test('a date chosen on an earlier day is kept', () async {
    final earlier = _formOpenedAt.subtract(const Duration(hours: 30));
    await createExpense()(expense(earlier));

    expect(transactions.created.single.date, earlier);
  });
}
