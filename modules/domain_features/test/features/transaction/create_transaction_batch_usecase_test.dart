import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:domain_features/core/constant/currency_constants.dart';
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:domain_features/features/transaction/domain/usecases/create_transaction_batch_usecase.dart';
import 'package:domain_features/features/transaction/domain/usecases/create_transaction_usecase.dart';
import 'package:domain_features/features/wallet/domain/entities/wallet_entity.dart';
import 'package:domain_features/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:domain_features/features/wallet/domain/usecases/get_wallet_book_balance_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiple_result/multiple_result.dart';

class _FakeCreateTransaction implements CreateTransactionUseCase {
  _FakeCreateTransaction({this.failAt});

  final int? failAt;
  final List<CreateTransactionParams> received = [];

  @override
  Future<Result<TransactionEntity, CcFailure>> call(
    CreateTransactionParams params,
  ) async {
    received.add(params);
    if (received.length - 1 == failAt) {
      return const Error(ValidationFailure('boom'));
    }
    return Success(
      TransactionEntity(
        id: '${received.length}',
        type: params.type,
        amount: params.amount,
        category: params.categoryLabel,
        categoryId: params.categoryId,
        walletId: params.walletId,
        date: params.date,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWalletRepository implements WalletRepository {
  _FakeWalletRepository(this._wallets);

  final Map<String, WalletEntity> _wallets;

  @override
  Future<Result<WalletEntity, CcFailure>> getWallet(String id) async {
    final wallet = _wallets[id];
    return wallet == null
        ? const Error(ValidationFailure('missing'))
        : Success(wallet);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBookBalance implements GetWalletBookBalanceUseCase {
  _FakeBookBalance(this._balances);

  final Map<String, int> _balances;

  @override
  Future<Result<int, CcFailure>> call(String walletId) async =>
      Success(_balances[walletId] ?? 0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletEntity _wallet(String id, {String? currency}) => WalletEntity(
  id: id,
  name: id,
  balance: 0,
  iconCode: 0,
  type: WalletType.cash,
  currencyCode: currency ?? CurrencyConstants.currentPrimaryCurrency,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

CreateTransactionParams _params(
  int amount, {
  String walletId = 'w1',
  String type = TransactionType.expense,
}) => CreateTransactionParams(
  type: type,
  amount: amount,
  categoryId: 'food',
  walletId: walletId,
  date: DateTime(2026, 1, 1),
);

CreateTransactionBatchUseCase _useCase(
  _FakeCreateTransaction create, {
  Map<String, int> balances = const {'w1': 1000},
  List<WalletEntity>? wallets,
}) => CreateTransactionBatchUseCase(
  create,
  _FakeWalletRepository({
    for (final w in wallets ?? [_wallet('w1')]) w.id: w,
  }),
  _FakeBookBalance(balances),
);

void main() {
  test('saves every item in order and reports the count', () async {
    final create = _FakeCreateTransaction();

    final result = await _useCase(
      create,
    ).call([_params(100), _params(200), _params(300)]);

    expect(result.isSuccess, isTrue);
    expect(result.saved, 3);
    expect(create.received.map((p) => p.amount), [100, 200, 300]);
  });

  test(
    'rejects the whole batch when summed expenses exceed the wallet',
    () async {
      final create = _FakeCreateTransaction();

      final result = await _useCase(
        create,
      ).call([_params(600), _params(300), _params(200)]);

      expect(result.isSuccess, isFalse);
      expect(result.saved, 0);
      expect(result.failedAt, 2);
      expect(create.received, isEmpty);
    },
  );

  test('income never counts against the balance', () async {
    final create = _FakeCreateTransaction();

    final result = await _useCase(
      create,
    ).call([_params(5000, type: TransactionType.income), _params(900)]);

    expect(result.isSuccess, isTrue);
    expect(result.saved, 2);
  });

  test('balances are tracked per wallet', () async {
    final create = _FakeCreateTransaction();

    final result = await _useCase(
      create,
      balances: {'w1': 500, 'w2': 500},
      wallets: [_wallet('w1'), _wallet('w2')],
    ).call([_params(400), _params(400, walletId: 'w2')]);

    expect(result.isSuccess, isTrue);
  });

  test('skips the pre-check for a wallet in another currency', () async {
    final create = _FakeCreateTransaction();

    final result = await _useCase(
      create,
      balances: {'w1': 1},
      wallets: [_wallet('w1', currency: 'XXX')],
    ).call([_params(500)]);

    expect(result.isSuccess, isTrue);
  });

  test('stops at the first failure and reports how far it got', () async {
    final create = _FakeCreateTransaction(failAt: 1);

    final result = await _useCase(
      create,
    ).call([_params(100), _params(100), _params(100)]);

    expect(result.isSuccess, isFalse);
    expect(result.saved, 1);
    expect(result.failedAt, 1);
    expect(create.received.length, 2);
  });
}
