import 'dart:async';

import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../features/budget_limit/data/datasources/budget_limit_sync_datasource.dart';
import '../../../features/budget_limit/data/models/budget_limit_model.dart';
import '../../../features/category/data/datasources/category_sync_datasource.dart';
import '../../../features/category/data/models/category_model.dart';
import '../../../features/loan/data/datasources/loan_sync_datasource.dart';
import '../../../features/loan/data/models/loan_model.dart';
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
  final LoanSyncDataSource _loanSync;

  FinancialDataSyncService(
    this._syncService,
    this._session,
    this._connection,
    this._walletSync,
    this._transactionSync,
    this._budgetSync,
    this._reconciliationSync,
    this._categorySync,
    this._loanSync,
  );

  bool get _isAuthenticated => _session.currentUser != null;

  String? get _userId => _session.currentUser?.id;

  /// Whether the device currently has internet access — drives the
  /// sync-status indicator. Kept live by [startWatching].
  final RxBool isOnline = true.obs;

  /// Count of locally-stored records not yet backed up to Cloud (across all
  /// synced entity types) — also drives the sync-status icon. Recomputed
  /// after every [syncAll] call, so it stays fresh automatically since every
  /// write-repository already fires `syncAll()` after each local write.
  final RxInt pendingCount = 0.obs;

  StreamSubscription<InternetStatus>? _connectivitySubscription;

  /// Starts watching connectivity in the background and seeds the initial
  /// [pendingCount]. Call once at app boot (mirrors `NotificationService
  /// .init()`); safe to call more than once.
  void startWatching() {
    _connectivitySubscription ??= _connection.onStatusChange.listen((status) {
      isOnline.value = status == InternetStatus.connected;
    });
    pendingCount.value = _countPending();
  }

  Future<void> syncAll() async {
    try {
      final userId = _userId;
      if (userId != null && await _connection.hasInternetAccess) {
        await _syncPendingWallets(userId);
        await _syncPendingTransactions(userId);
        await _syncPendingBudgets(userId);
        await _syncPendingReconciliations(userId);
        await _syncPendingCategories(userId);
        await _syncPendingLoans(userId);
      }
    } catch (e) {
      'syncAll failed: $e'.Log('FinancialDataSyncService');
    } finally {
      pendingCount.value = _countPending();
    }
  }

  int _countPending() {
    return _countPendingInBox<WalletHiveModel>(
          CcHiveBox.WALLET_BOX_NAME,
          (m) => m.syncMetadata.status,
        ) +
        _countPendingInBox<TransactionModel>(
          CcHiveBox.TRANSACTION_BOX_NAME,
          (m) => m.syncMetadata.status,
        ) +
        _countPendingInBox<BudgetLimitModel>(
          CcHiveBox.BUDGET_BOX_NAME,
          (m) => m.syncMetadata.status,
        ) +
        _countPendingInBox<ReconciliationModel>(
          CcHiveBox.RECONCILIATION_BOX_NAME,
          (m) => m.syncMetadata.status,
        ) +
        _countPendingInBox<CategoryModel>(
          CcHiveBox.CATEGORY_BOX_NAME,
          (m) => m.syncMetadata.status,
        ) +
        _countPendingInBox<LoanModel>(
          CcHiveBox.LOAN_BOX_NAME,
          (m) => m.syncMetadata.status,
        );
  }

  int _countPendingInBox<T>(
    String boxName,
    SyncStatus Function(T) statusOf,
  ) {
    try {
      if (!Hive.isBoxOpen(boxName)) return 0;
      final box = Hive.box<T>(boxName);
      return box.values.where((m) {
        final status = statusOf(m);
        return status == SyncStatus.pending || status == SyncStatus.failed;
      }).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> pullFromFirestore() async {
    try {
      final userId = _userId;
      if (userId == null) return;
      if (!await _connection.hasInternetAccess) return;

      await _pullWallets(userId);
      await _pullTransactions(userId);
      await _pullBudgets(userId);
      await _pullReconciliations(userId);
      await _pullCategories(userId);
      await _pullLoans(userId);
    } catch (e) {
      'pullFromFirestore failed: $e'.Log('FinancialDataSyncService');
    }
  }

  Future<void> _syncPendingWallets(String userId) async {
    if (!Hive.isBoxOpen(CcHiveBox.WALLET_BOX_NAME)) return;
    Box<WalletHiveModel> box;
    try {
      box = Hive.box<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
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
    if (!Hive.isBoxOpen(CcHiveBox.TRANSACTION_BOX_NAME)) return;
    Box<TransactionModel> box;
    try {
      box = Hive.box<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
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
    if (!Hive.isBoxOpen(CcHiveBox.BUDGET_BOX_NAME)) return;
    Box<BudgetLimitModel> box;
    try {
      box = Hive.box<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
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
    if (!Hive.isBoxOpen(CcHiveBox.RECONCILIATION_BOX_NAME)) return;
    Box<ReconciliationModel> box;
    try {
      box = Hive.box<ReconciliationModel>(CcHiveBox.RECONCILIATION_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
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
    if (!Hive.isBoxOpen(CcHiveBox.CATEGORY_BOX_NAME)) return;
    Box<CategoryModel> box;
    try {
      box = Hive.box<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
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

  Future<void> _syncPendingLoans(String userId) async {
    if (!Hive.isBoxOpen(CcHiveBox.LOAN_BOX_NAME)) return;
    Box<LoanModel> box;
    try {
      box = Hive.box<LoanModel>(CcHiveBox.LOAN_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
    for (final model in box.values) {
      final status = model.syncMetadata.status;
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        await _syncEntity<LoanModel>(
          model: model,
          syncFn: _loanSync.syncLoan,
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
    final box = await _openBox<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);
    if (box == null) return;
    await _pullAndMerge<WalletHiveModel>(
      userId: userId,
      collectionName: 'wallets',
      box: box,
      fromFirestore: WalletHiveModel.fromFirestoreData,
    );
  }

  Future<void> _pullTransactions(String userId) async {
    final box = await _openBox<TransactionModel>(
      CcHiveBox.TRANSACTION_BOX_NAME,
    );
    if (box == null) return;
    await _pullAndMerge<TransactionModel>(
      userId: userId,
      collectionName: 'transactions',
      box: box,
      fromFirestore: TransactionModel.fromFirestoreData,
    );
  }

  Future<void> _pullBudgets(String userId) async {
    final box = await _openBox<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME);
    if (box == null) return;
    await _pullAndMerge<BudgetLimitModel>(
      userId: userId,
      collectionName: 'budgets',
      box: box,
      fromFirestore: BudgetLimitModel.fromFirestoreData,
    );
  }

  Future<void> _pullReconciliations(String userId) async {
    final box = await _openBox<ReconciliationModel>(
      CcHiveBox.RECONCILIATION_BOX_NAME,
    );
    if (box == null) return;
    await _pullAndMerge<ReconciliationModel>(
      userId: userId,
      collectionName: 'reconciliations',
      box: box,
      fromFirestore: ReconciliationModel.fromFirestoreData,
    );
  }

  Future<void> _pullCategories(String userId) async {
    final box = await _openBox<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME);
    if (box == null) return;
    await _pullAndMerge<CategoryModel>(
      userId: userId,
      collectionName: 'categories',
      box: box,
      fromFirestore: CategoryModel.fromFirestoreData,
    );
  }

  Future<void> _pullLoans(String userId) async {
    final box = await _openBox<LoanModel>(CcHiveBox.LOAN_BOX_NAME);
    if (box == null) return;
    await _pullAndMerge<LoanModel>(
      userId: userId,
      collectionName: 'loans',
      box: box,
      fromFirestore: LoanModel.fromFirestoreData,
    );
  }

  Future<Box<T>?> _openBox<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      }
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      'Failed to open box $boxName: $e'.Log('FinancialDataSyncService');
      return null;
    }
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
      'Sync failed for entity: $e'.Log('FinancialDataSyncService');
    }
  }

  Future<void> _pullAndMerge<T>({
    required String userId,
    required String collectionName,
    required Box<T> box,
    required T Function(Map<String, dynamic>, String) fromFirestore,
  }) async {
    try {
      final remoteData = await _syncService.fetchFromFirestore(
        userId: userId,
        collectionName: collectionName,
      );

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
      'Pull failed for $collectionName: $e'.Log('FinancialDataSyncService');
    }
  }

  String? _getLocalId<T>(T model) {
    if (model is WalletHiveModel) return model.id;
    if (model is TransactionModel) return model.id;
    if (model is BudgetLimitModel) return model.id;
    if (model is ReconciliationModel) return model.id;
    if (model is CategoryModel) return model.id;
    if (model is LoanModel) return model.id;
    return null;
  }

  DateTime? _getLastModifiedAt<T>(T model) {
    if (model is WalletHiveModel) return model.lastModifiedAt;
    if (model is TransactionModel) return model.lastModifiedAt;
    if (model is BudgetLimitModel) return model.lastModifiedAt;
    if (model is ReconciliationModel) return model.lastModifiedAt;
    if (model is CategoryModel) return model.lastModifiedAt;
    if (model is LoanModel) return model.lastModifiedAt;
    return null;
  }
}
