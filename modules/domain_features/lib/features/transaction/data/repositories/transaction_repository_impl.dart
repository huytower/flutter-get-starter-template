import 'dart:async';

import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../datasources/local/transaction_local_datasource.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl
    with CcBaseRepository
    implements TransactionRepository {
  @factoryMethod
  TransactionRepositoryImpl({
    required TransactionLocalDataSource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  final TransactionLocalDataSource _local;
  final FinancialDataSyncService _syncService;

  Future<List<TransactionEntity>> _allSortedDesc() async {
    final models = await _local.getAll();
    final entities =
        models.map((m) => m.toEntity()).where((e) => !e.isDeleted).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return entities;
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getListTransactions() {
    return safeRequest(() => _allSortedDesc());
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactions(
    PaginationRequest request,
  ) {
    return safeRequest(() async {
      final all = await _allSortedDesc();
      final start = (request.page - 1) * request.itemsPerPage;
      if (start >= all.length) return <TransactionEntity>[];
      return all.skip(start).take(request.itemsPerPage).toList();
    });
  }

  @override
  Future<Result<void, CcFailure>> createTransaction(
    TransactionEntity transaction,
  ) {
    return safeRequest(() async {
      final model = TransactionModel.fromEntity(transaction);
      await _local.add(model);

      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id ?? ''),
      );
      await _local.update(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteTransaction(String id) {
    return safeRequest(() async {
      await _local.delete(id);
      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> softDeleteByWallet(String walletId) {
    return safeRequest(() async {
      await _local.softDeleteByWallet(walletId, DateTime.now());
      _syncService.syncAll();
    });
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByWallet(
    String walletId,
  ) {
    return safeRequest(() async {
      final all = await _allSortedDesc();
      return all.where((t) => t.walletId == walletId).toList();
    });
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByBudget(
    String budgetId,
  ) {
    return safeRequest(() async {
      final all = await _allSortedDesc();
      return all.where((t) => t.budgetId == budgetId).toList();
    });
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByPeriod(
    DateTime start,
    DateTime end,
  ) {
    return safeRequest(() async {
      final all = await _allSortedDesc();
      return all
          .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
          .toList();
    });
  }
}
