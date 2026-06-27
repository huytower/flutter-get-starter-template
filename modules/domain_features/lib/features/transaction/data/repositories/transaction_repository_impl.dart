import 'dart:async';
import 'dart:math';

import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../datasources/remote/transaction_remote.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl with CcBaseRepository
    implements TransactionRepository {
  @factoryMethod
  TransactionRepositoryImpl({required TransactionRemote remote})
    : _remote = remote;

  final TransactionRemote _remote;

  static const _categories = [
    'Food & Drink',
    'Transport',
    'Shopping',
    'Health',
    'Entertainment',
    'Salary',
    'Freelance',
    'Investment',
  ];

  static const _notes = [
    'Lunch at cafe',
    'Grab ride home',
    'New headphones',
    'Gym membership',
    'Movie night',
    'Monthly salary',
    'Project payment',
    'Dividend',
  ];

  List<TransactionEntity> _generateFakeTransactions(int count) {
    final random = Random();
    return List.generate(count, (index) {
      final isExpense = random.nextBool();
      return TransactionEntity(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}_$index',
        type: isExpense ? 'expense' : 'income',
        amount: (random.nextDouble() * 900 + 50).roundToDouble(),
        category: _categories[random.nextInt(_categories.length)],
        note: _notes[random.nextInt(_notes.length)],
        date: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        walletId: 'wallet_${random.nextInt(3)}',
      );
    });
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getListTransactions() {
    return safeRequest(() async {
      final fakeData = _generateFakeTransactions(20);
      return fakeData;
    });
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactions(
    PaginationRequest request,
  ) {
    return safeRequest(() async {
      final fakeData = _generateFakeTransactions(request.itemsPerPage);
      return fakeData;
    });
  }
}
