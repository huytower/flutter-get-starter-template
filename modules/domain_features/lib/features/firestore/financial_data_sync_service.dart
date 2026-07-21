import 'dart:developer' as developer;

import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../features/budget_limit/data/datasources/budget_limit_sync_datasource.dart';
import '../../../features/budget_limit/data/models/budget_limit_model.dart';
import '../../../features/category/data/datasources/category_sync_datasource.dart';
import '../../../features/category/data/models/category_model.dart';
import '../../../features/reconciliation/data/datasources/reconciliation_sync_datasource.dart';
import '../../../features/reconciliation/data/models/reconciliation_model.dart';
import '../../../features/transaction/data/datasources/transaction_sync_datasource.dart';
import '../../../features/transaction/data/models/transaction_model.dart';
import '../../../features/wallet/data/datasources/wallet_sync_datasource.dart';
import '../../../features/wallet/data/models/wallet_hive_model.dart';
import 'enum/sync_status.dart';

@lazySingleton
class FinancialDataSyncService {
  final FirestoreSyncService _syncService;
  final SessionContract _session;
  final InternetConnection _connection;
  final WalletSyncDataSource _walletSync;
  final TransactionSyncDataSource _transactionSync;
  final BudgetLimitSyncDataSource _budgetSync;
  final ReconciliationSyncDataSource _reconciliationSync;
  final CategorySyncDataSource _categorySync;

  FinancialDataSyncService(
    this._syncService,
    this._session,
    this._connection,
    this._walletSync,
    this._transactionSync,
    this._budgetSync,
    this._reconciliationSync,
    this._categorySync,
  );

  bool get _isAuthenticated => _session.currentUser != null;
  String? get _userId => _session.currentUser?.id;

  Future<void> syncAll() async {
    final userId = _userId;
    if (userId == null) return;
    if (!await _connection.hasInternetAccess) return;

    await _syncPendingWallets(userId);
    await _syncPendingTransactions(userId);
    await _syncPendingBudgets(userId);
    await _syncPendingReconciliations(userId);
    await _syncPendingCategories(userId);
  }

  Future<void> pullFromFirestore() async {
    final userId = _userId;
    if (userId == null) return;
    if (!await _connection.hasInternetAccess) return;

    await _pullWallets(userId);
    await _pullTransactions(userId);
    await _pullBudgets(userId);
    await _pullReconciliations(userId);
    await _pullCategories(userId);
  }

  Future<void> _syncPendingWallets(String userId) async {
    final box = Hive.box<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);
    for (final model in box.values) {
      final status = model.syncMetadata.status;
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        await _syncEntity<WalletHiveModel>(
          model: model,
          syncFn: _walletSync.syncWallet,
          box: box,
          updateFn: (m, remoteId) => m.copyWithSyncMetadata(
            m.syncMetadata.copyWith(
              remoteId: remoteId,
              status: SyncStatus.synced,
              lastSyncedAt: DateTime.now(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _syncPendingTransactions(String userId) async {
    final box = Hive.box<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME);
    for (final model in box.values) {
      final status = model.syncMetadata.status;
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        await _syncEntity<TransactionModel>(
          model: model,
          syncFn: _transactionSync.syncTransaction,
          box: box,
          updateFn: (m, remoteId) => m.copyWithSyncMetadata(
            m.syncMetadata.copyWith(
              remoteId: remoteId,
              status: SyncStatus.synced,
              lastSyncedAt: DateTime.now(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _syncPendingBudgets(String userId) async {
    final box = Hive.box<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME);
    for (final model in box.values) {
      final status = model.syncMetadata.status;
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        await _syncEntity<BudgetLimitModel>(
          model: model,
          syncFn: _budgetSync.syncBudget,
          box: box,
          updateFn: (m, remoteId) => m.copyWithSyncMetadata(
            m.syncMetadata.copyWith(
              remoteId: remoteId,
              status: SyncStatus.synced,
              lastSyncedAt: DateTime.now(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _syncPendingReconciliations(String userId) async {
    final box = Hive.box<ReconciliationModel>(
      CcHiveBox.RECONCILIATION_BOX_NAME,
    );
    for (final model in box.values) {
      final status = model.syncMetadata.status;
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        await _syncEntity<ReconciliationModel>(
          model: model,
          syncFn: _reconciliationSync.syncReconciliation,
          box: box,
          updateFn: (m, remoteId) => m.copyWithSyncMetadata(
            m.syncMetadata.copyWith(
              remoteId: remoteId,
              status: SyncStatus.synced,
              lastSyncedAt: DateTime.now(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _syncPendingCategories(String userId) async {
    final box = Hive.box<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME);
    for (final model in box.values) {
      final status = model.syncMetadata.status;
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        await _syncEntity<CategoryModel>(
          model: model,
          syncFn: _categorySync.syncCategory,
          box: box,
          updateFn: (m, remoteId) => m.copyWithSyncMetadata(
            m.syncMetadata.copyWith(
              remoteId: remoteId,
              status: SyncStatus.synced,
              lastSyncedAt: DateTime.now(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _pullWallets(String userId) async {
    await _pullAndMerge<WalletHiveModel>(
      userId: userId,
      collectionName: 'wallets',
      boxName: CcHiveBox.WALLET_BOX_NAME,
      fromFirestore: WalletHiveModel.fromFirestoreData,
    );
  }

  Future<void> _pullTransactions(String userId) async {
    await _pullAndMerge<TransactionModel>(
      userId: userId,
      collectionName: 'transactions',
      boxName: CcHiveBox.TRANSACTION_BOX_NAME,
      fromFirestore: TransactionModel.fromFirestoreData,
    );
  }

  Future<void> _pullBudgets(String userId) async {
    await _pullAndMerge<BudgetLimitModel>(
      userId: userId,
      collectionName: 'budgets',
      boxName: CcHiveBox.BUDGET_BOX_NAME,
      fromFirestore: BudgetLimitModel.fromFirestoreData,
    );
  }

  Future<void> _pullReconciliations(String userId) async {
    await _pullAndMerge<ReconciliationModel>(
      userId: userId,
      collectionName: 'reconciliations',
      boxName: CcHiveBox.RECONCILIATION_BOX_NAME,
      fromFirestore: ReconciliationModel.fromFirestoreData,
    );
  }

  Future<void> _pullCategories(String userId) async {
    await _pullAndMerge<CategoryModel>(
      userId: userId,
      collectionName: 'categories',
      boxName: CcHiveBox.CATEGORY_BOX_NAME,
      fromFirestore: CategoryModel.fromFirestoreData,
    );
  }

  Future<void> _syncEntity<T>({
    required T model,
    required Future<String?> Function(T) syncFn,
    required Box<dynamic> box,
    required T Function(T, String) updateFn,
  }) async {
    try {
      final remoteId = await syncFn(model);
      if (remoteId != null) {
        final updated = updateFn(model, remoteId);
        final key = _getLocalId(model);
        if (key != null) await box.put(key, updated);
      }
    } catch (e) {
      developer.log('Sync failed for entity: $e', error: e);
    }
  }

  Future<void> _pullAndMerge<T>({
    required String userId,
    required String collectionName,
    required String boxName,
    required T Function(Map<String, dynamic>, String) fromFirestore,
  }) async {
    try {
      final remoteData = await _syncService.fetchFromFirestore(
        userId: userId,
        collectionName: collectionName,
      );

      final box = Hive.box(boxName);

      for (final data in remoteData) {
        final localId = data['localId'] as String;
        final existing = box.get(localId);

        if (existing == null) {
          final model = fromFirestore(data, localId);
          await box.put(localId, model);
        } else {
          final remoteModifiedAt = data['lastModifiedAt'] as String?;
          final parsedRemote = remoteModifiedAt != null
              ? DateTime.tryParse(remoteModifiedAt)
              : null;

          final localModifiedAt = _getLastModifiedAt(existing);

          if (localModifiedAt == null ||
              (parsedRemote != null && parsedRemote.isAfter(localModifiedAt))) {
            final model = fromFirestore(data, localId);
            await box.put(localId, model);
          }
        }
      }
    } catch (e) {
      developer.log('Pull failed for $collectionName: $e', error: e);
    }
  }

  String? _getLocalId<T>(T model) {
    if (model is WalletHiveModel) return model.id;
    if (model is TransactionModel) return model.id;
    if (model is BudgetLimitModel) return model.id;
    if (model is ReconciliationModel) return model.id;
    if (model is CategoryModel) return model.id;
    return null;
  }

  DateTime? _getLastModifiedAt<T>(T model) {
    if (model is WalletHiveModel) return model.lastModifiedAt;
    if (model is TransactionModel) return model.lastModifiedAt;
    if (model is BudgetLimitModel) return model.lastModifiedAt;
    if (model is ReconciliationModel) return model.lastModifiedAt;
    if (model is CategoryModel) return model.lastModifiedAt;
    return null;
  }
}
