import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/domain/entities/liability_entity.dart';
import 'package:domain_features/core/domain/entities/transaction_entity.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:domain_features/core/exchange_rates/currency_conversion_service.dart';
import 'package:domain_features/core/exchange_rates/exchange_rate_repository.dart';
import 'package:domain_features/features/liability/domain/entities/liability_balance_entity.dart';
import 'package:domain_features/features/liability/domain/repositories/liability_repository.dart';
import 'package:domain_features/features/liability/domain/usecases/get_liability_balances_usecase.dart';
import 'package:domain_features/features/liability/domain/usecases/record_liability_payment_usecase.dart';
import 'package:domain_features/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:multiple_result/multiple_result.dart';

// Simulates recording a repayment / collection, for a stored liability and for
// a synthetic one (debt transactions with no stored record).

final _epoch = DateTime.utc(2026);

LiabilityEntity _liability(String id, String direction) => LiabilityEntity(
  id: id,
  direction: direction,
  principalAmount: 500,
  categoryId: 'cat',
  categoryLabel: 'Bank loan',
  walletId: 'cash',
  repaymentMethod: LiabilityRepaymentMethod.lumpSum,
  createdAt: _epoch,
  updatedAt: _epoch,
);

class _Liabilities implements LiabilityRepository {
  final Map<String, LiabilityEntity> store = {};
  final List<LiabilityEntity> updates = [];

  @override
  Future<Result<LiabilityEntity?, CcFailure>> findLiability(String id) async =>
      Success(store[id]);

  @override
  Future<Result<void, CcFailure>> updateLiability(LiabilityEntity l) async {
    updates.add(l);
    store[l.id] = l;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionRepository {
  final List<TransactionEntity> created = [];

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

class _Wallets implements WalletRepository {
  @override
  Future<Result<WalletEntity, CcFailure>> getWallet(String id) async => Success(
    WalletEntity(
      id: id,
      name: id,
      balance: 0,
      iconCode: 0,
      type: WalletType.cash,
      createdAt: _epoch,
      updatedAt: _epoch,
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Balance implements GetWalletBookBalanceUseCase {
  _Balance(this.available);

  final int available;

  @override
  Future<Result<int, CcFailure>> call(String walletId) async =>
      Success(available);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRates implements ExchangeRateRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Liabilities liabilities;
  late _Transactions transactions;

  setUp(() {
    liabilities = _Liabilities();
    transactions = _Transactions();
  });

  RecordLiabilityPaymentUseCase useCase({int available = 1000}) =>
      RecordLiabilityPaymentUseCase(
        liabilities,
        transactions,
        _Wallets(),
        _Balance(available),
        CurrencyConversionService(_NoRates()),
      );

  RecordLiabilityPaymentParams pay(
    String id, {
    int amount = 100,
    bool settle = true,
    LiabilityEntity? listed,
    int? outstanding,
  }) => RecordLiabilityPaymentParams(
    liabilityId: id,
    isSettlement: settle,
    walletId: 'cash',
    amount: amount,
    date: DateTime.now().subtract(const Duration(minutes: 1)),
    listedLiability: listed,
    outstandingBalance: outstanding,
  );

  test('stored borrow: a repayment is a debtRepay linked to it', () async {
    liabilities.store['loan'] = _liability('loan', LiabilityDirection.borrow);

    final result = await useCase()(pay('loan'));

    expect(result.isSuccess(), isTrue);
    final txn = transactions.created.single;
    expect(txn.type, TransactionType.debtRepay);
    expect(txn.liabilityId, 'loan');
    expect(txn.amount, 100);
    expect(liabilities.updates.single.id, 'loan', reason: 'moved to front');
  });

  test('stored lend: lending more is a debtLend and needs the money', () async {
    liabilities.store['lent'] = _liability('lent', LiabilityDirection.lend);

    final short = await useCase(available: 50)(pay('lent', settle: false));
    expect(
      short.tryGetError()?.message,
      PrjLocaleKeys.transaction_validation_insufficient_balance,
    );
    expect(transactions.created, isEmpty);

    final ok = await useCase()(pay('lent', settle: false));
    expect(ok.isSuccess(), isTrue);
    expect(transactions.created.single.type, TransactionType.debtLend);
  });

  test('collecting a loan brings money in: no balance check', () async {
    liabilities.store['lent'] = _liability('lent', LiabilityDirection.lend);

    final result = await useCase(available: 0)(pay('lent'));

    expect(result.isSuccess(), isTrue);
    expect(transactions.created.single.type, TransactionType.debtCollect);
  });

  test(
    'synthetic liability: recorded into its group, no record written',
    () async {
      final synthetic = _liability(
        '${syntheticLiabilityIdPrefix}borrow_bank loan',
        LiabilityDirection.borrow,
      );

      final result = await useCase()(pay(synthetic.id, listed: synthetic));

      expect(result.isSuccess(), isTrue);
      final txn = transactions.created.single;
      expect(txn.liabilityId, isNull, reason: 'joins the group by label');
      expect(txn.category, 'Bank loan');
      expect(
        liabilities.updates,
        isEmpty,
        reason: 'no principal counted twice',
      );
    },
  );

  test('unknown liability without a listed one is a clean error', () async {
    final result = await useCase()(pay('missing'));

    expect(
      result.tryGetError()?.message,
      PrjLocaleKeys.transaction_liability_not_found,
    );
    expect(transactions.created, isEmpty);
  });

  test('a listed liability with another id is not trusted', () async {
    final other = _liability('other', LiabilityDirection.borrow);

    final result = await useCase()(pay('missing', listed: other));

    expect(result.isError(), isTrue);
    expect(transactions.created, isEmpty);
  });

  test('a repayment above what is still owed is refused', () async {
    liabilities.store['loan'] = _liability('loan', LiabilityDirection.borrow);

    final over = await useCase()(pay('loan', amount: 301, outstanding: 300));
    expect(
      over.tryGetError()?.message,
      PrjLocaleKeys.transaction_liability_exceeds_outstanding,
    );
    expect(transactions.created, isEmpty);

    final exact = await useCase()(pay('loan', amount: 300, outstanding: 300));
    expect(exact.isSuccess(), isTrue, reason: 'paying it off exactly is fine');
  });

  test('a settled or over-collected loan accepts no more collection', () async {
    liabilities.store['lent'] = _liability('lent', LiabilityDirection.lend);

    final result = await useCase()(pay('lent', amount: 1, outstanding: -3950));

    expect(result.isError(), isTrue);
    expect(transactions.created, isEmpty);
  });

  test('lending or borrowing more is not capped by the balance', () async {
    liabilities.store['lent'] = _liability('lent', LiabilityDirection.lend);

    final result = await useCase()(
      pay('lent', amount: 900, settle: false, outstanding: 0),
    );

    expect(result.isSuccess(), isTrue);
  });

  test('display value: never negative, 0 once settled', () {
    final loan = _liability('lent', LiabilityDirection.lend);
    expect(
      LiabilityBalanceEntity(
        liability: loan,
        outstandingBalance: -3950,
      ).remainingToShow,
      0,
    );
    expect(
      LiabilityBalanceEntity(
        liability: loan,
        outstandingBalance: 120,
      ).remainingToShow,
      120,
    );
  });

  test('validation: amount, wallet and future date', () async {
    liabilities.store['loan'] = _liability('loan', LiabilityDirection.borrow);

    expect((await useCase()(pay('loan', amount: 0))).isError(), isTrue);
    final future = RecordLiabilityPaymentParams(
      liabilityId: 'loan',
      walletId: 'cash',
      amount: 10,
      date: DateTime.now().add(const Duration(days: 1)),
    );
    expect((await useCase()(future)).isError(), isTrue);
    expect(transactions.created, isEmpty);
  });
}
