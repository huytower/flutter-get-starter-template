import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/transaction/data/datasources/local/transaction_local_datasource.dart';
import 'package:domain_features/features/transaction/data/datasources/transaction_sync_datasource.dart';
import 'package:domain_features/features/transaction/data/models/transaction_model.dart';
import 'package:domain_features/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocal implements TransactionLocalDataSource {
  _FakeLocal(this._models);

  final List<TransactionModel> _models;

  @override
  Future<List<TransactionModel>> getAll() async => _models;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSync implements TransactionSyncDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSyncService implements FinancialDataSyncService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TransactionModel _model(String type, int index) => TransactionModel.fromEntity(
  TransactionEntity(
    id: '${index}_$type',
    type: type,
    amount: 100 + index,
    category: '',
    date: DateTime(2026, 1, 1).add(Duration(days: index)),
    walletId: 'w',
  ),
);

TransactionRepositoryImpl _repository(List<TransactionModel> models) =>
    TransactionRepositoryImpl(
      local: _FakeLocal(models),
      syncDataSource: _FakeSync(),
      syncService: _FakeSyncService(),
    );

void main() {
  final mixed = [
    _model(TransactionType.expense, 1),
    _model(TransactionType.income, 2),
    _model(TransactionType.transferOut, 3),
    _model(TransactionType.expense, 4),
    _model(TransactionType.debtBorrow, 5),
    _model(TransactionType.income, 6),
  ];

  group('TransactionRepositoryImpl.getTransactions', () {
    test('returns every type newest first when no type is given', () async {
      final result = await _repository(
        mixed,
      ).getTransactions(const PaginationRequest(page: 1, itemsPerPage: 100));

      expect(result.tryGetSuccess()!.map((t) => t.id).toList(), [
        '6_income',
        '5_debt_borrow',
        '4_expense',
        '3_transfer_out',
        '2_income',
        '1_expense',
      ]);
    });

    test('returns only the requested type', () async {
      final result = await _repository(mixed).getTransactions(
        const PaginationRequest(page: 1, itemsPerPage: 100),
        type: TransactionType.income,
      );

      final transactions = result.tryGetSuccess()!;
      expect(transactions.length, 2);
      expect(transactions.every((t) => t.type == TransactionType.income), true);
    });

    test('applies the page window after filtering by type', () async {
      final result = await _repository(mixed).getTransactions(
        const PaginationRequest(page: 1, itemsPerPage: 2),
        type: TransactionType.expense,
      );

      final transactions = result.tryGetSuccess()!;
      expect(transactions.length, 2);
      expect(
        transactions.every((t) => t.type == TransactionType.expense),
        true,
      );
    });

    test('skips and takes within the filtered list, newest first', () async {
      final repository = _repository(mixed);

      final first = await repository.getTransactions(
        const PaginationRequest(page: 1, itemsPerPage: 1),
        type: TransactionType.expense,
      );
      final second = await repository.getTransactions(
        const PaginationRequest(page: 2, itemsPerPage: 1),
        type: TransactionType.expense,
      );

      expect(first.tryGetSuccess()!.map((t) => t.id), ['4_expense']);
      expect(second.tryGetSuccess()!.map((t) => t.id), ['1_expense']);
    });

    test('returns an empty page past the filtered results', () async {
      final result = await _repository(mixed).getTransactions(
        const PaginationRequest(page: 2, itemsPerPage: 2),
        type: TransactionType.income,
      );

      expect(result.tryGetSuccess(), isEmpty);
    });
  });
}
