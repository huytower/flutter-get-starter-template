import 'dart:async';

import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:domain_features/core/data/repositories/prj_base_repository.dart';
import 'package:domain_features/export_domain_features.dart';
import 'package:domain_features/features/firestore/models/sync_metadata.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../datasources/local/transaction_local_datasource.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl
    with PrjBaseRepository
    implements TransactionRepository {
  @factoryMethod
  TransactionRepositoryImpl({
    required this.crashReporter,
    required TransactionLocalDataSource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  @override
  final CcCrashReporter crashReporter;
  final TransactionLocalDataSource _local;
  final FinancialDataSyncService _syncService;

  Future<List<TransactionEntity>> _allSortedDesc() async {
    final models = await _local.getAll();
    final entities = models
        .map((m) => m.toEntity())
        .where((e) => !e.hasDeleted)
        .toList();

    // Sort by sortKey descending (latest recorded first).
    // This ensures creation-order stability across all forms and types.
    entities.sort((a, b) => b.sortKey.compareTo(a.sortKey));

    return entities;
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getListTransactions() {
    return safeRequest(() => _allSortedDesc());
  }

  @override
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactions(
    CcPaginationRequest request, {
    String? type,
  }) {
    return safeRequest(() async {
      final sorted = await _allSortedDesc();
      final all = type == null
          ? sorted
          : sorted.where((t) => t.type == type).toList();
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
  Future<Result<void, CcFailure>> updateTransaction(
    TransactionEntity transaction,
  ) {
    return safeRequest(() async {
      final model = TransactionModel.fromEntity(transaction);
      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id ?? ''),
      );
      await _local.update(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteTransaction(String id) {
    // Soft delete (BR §4.B): the record keeps a `deletedAt` stamp and is
    // marked pending, so the delete syncs like any edit — also when offline,
    // and a later pull can't bring the transaction back.
    return safeRequest(() async {
      await _local.softDeleteByIds([id], DateTime.now());
      '[DeleteTransaction] soft-deleted $id (pending sync)'.Log(
        'DeleteTransaction',
      );
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
  Future<Result<void, CcFailure>> softDeleteByIds(List<String> ids) {
    return safeRequest(() async {
      await _local.softDeleteByIds(ids, DateTime.now());
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
  Future<Result<List<TransactionEntity>, CcFailure>> getTransactionsByLiability(
    String liabilityId,
  ) {
    return safeRequest(() async {
      final all = await _allSortedDesc();
      return all.where((t) => t.liabilityId == liabilityId).toList();
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
