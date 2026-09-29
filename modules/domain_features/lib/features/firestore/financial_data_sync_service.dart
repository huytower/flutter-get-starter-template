import 'dart:async';

import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/sync_trace.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../features/budget_limit/data/datasources/budget_limit_sync_datasource.dart';
import '../../../features/budget_limit/data/models/budget_limit_model.dart';
import '../../../features/category/data/datasources/category_sync_datasource.dart';
import '../../../features/category/data/models/category_model.dart';
import '../../../features/liability/data/datasources/liability_sync_datasource.dart';
import '../../../features/liability/data/models/liability_model.dart';
import '../../../features/reconciliation/data/datasources/reconciliation_sync_datasource.dart';
import '../../../features/reconciliation/data/models/reconciliation_model.dart';
import '../../../features/transaction/data/datasources/transaction_sync_datasource.dart';
import '../../../features/transaction/data/models/transaction_model.dart';
import '../../../features/wallet/data/datasources/wallet_sync_datasource.dart';
import '../../../features/wallet/data/models/wallet_hive_model.dart';
import '../budget_allocation/presentation/get_x/budget_allocation_controller.dart';
import '../transaction/presentation/get_x/transaction_controller.dart';
import '../wallet/presentation/get_x/wallet_controller.dart';
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
  final LiabilitySyncDatasource _liabilitySync;

  FinancialDataSyncService(
    this._syncService,
    this._session,
    this._connection,
    this._walletSync,
    this._transactionSync,
    this._budgetSync,
    this._reconciliationSync,
    this._categorySync,
    this._liabilitySync,
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
  StreamSubscription<CcUserEntity?>? _sessionSubscription;
  Future<void>? _accountTransition;
  String? _observedUserId;

  /// Starts watching connectivity in the background and seeds the initial
  /// [pendingCount]. Call once at app boot (mirrors `NotificationService
  /// .init()`); safe to call more than once.
  void startWatching() {
    _connectivitySubscription ??= _connection.onStatusChange.listen((status) {
      isOnline.value = status == InternetStatus.connected;
    });
    _sessionSubscription ??= _session.userStream.listen(_handleSessionChange);
    pendingCount.value = _countPending();
    SyncTrace.log(
      'WATCH  startWatching() online=${isOnline.value} '
      'pendingCount=${pendingCount.value} authed=${_isAuthenticated}',
    );
  }

  Future<void> _handleSessionChange(CcUserEntity? user) {
    final nextUserId = user?.id;
    if (nextUserId == null && _observedUserId == null) return Future.value();
    if (nextUserId == _observedUserId) return Future.value();

    _accountTransition = (_accountTransition ?? Future.value()).then((_) async {
      if (nextUserId == null) {
        await _clearFinancialCache();
        _observedUserId = null;
        return;
      }

      if (_observedUserId != null && _observedUserId != nextUserId) {
        await _clearFinancialCache();
      }
      await _ensureCacheOwner(nextUserId);
      _observedUserId = nextUserId;
      await pullFromFirestore();
      await _refreshLoadedControllers();
    }).catchError((error) {
      'Account transition failed: $error'.Log('FinancialDataSyncService');
    });
    return _accountTransition!;
  }

  Future<void> _ensureCacheOwner(String userId) async {
    final previousOwner = CcAppStorage.instance.financialDataOwnerId;
    if (previousOwner != userId) {
      await _clearFinancialCache();
    }
    CcAppStorage.instance.financialDataOwnerId = userId;
    await CcAppStorage.instance.save();
  }

  Future<void> _clearFinancialCache() async {
    for (final boxName in CcHiveBox.financialBoxes) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).clear();
      } else {
        await Hive.deleteBoxFromDisk(boxName);
      }
    }
    CcAppStorage.instance.financialDataOwnerId = null;
    await CcAppStorage.instance.save();
    pendingCount.value = 0;
  }

  Future<void> _refreshLoadedControllers() async {
    if (Get.isRegistered<WalletController>()) {
      await Get.find<WalletController>().loadWallets();
    }
    if (Get.isRegistered<BudgetAllocationController>()) {
      await Get.find<BudgetAllocationController>().loadAll();
    }
    if (Get.isRegistered<TransactionController>()) {
      await Get.find<TransactionController>().refreshData();
    }
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
        await _syncPendingLiabilities(userId);
      }
    } catch (e) {
      'syncAll failed: $e'.Log('FinancialDataSyncService');
    } finally {
      pendingCount.value = _countPending();
      SyncTrace.log('PUSH  syncAll() done pendingCount=${pendingCount.value}');
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
        _countPendingInBox<LiabilityModel>(
          CcHiveBox.LIABILITY_BOX_NAME,
          (m) => m.syncMetadata.status,
        );
  }

  int _countPendingInBox<T>(String boxName, SyncStatus Function(T) statusOf) {
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
      if (userId == null) {
        SyncTrace.log('PULL  ABORTED — no authenticated userId');
        return;
      }
      if (!await _connection.hasInternetAccess) {
        SyncTrace.log('PULL  ABORTED — no internet');
        return;
      }

      SyncTrace.log('PULL  ===== begin pullFromFirestore userId=$userId =====');

      await _pullWallets(userId);
      await _pullTransactions(userId);
      await _pullBudgets(userId);
      await _pullReconciliations(userId);
      await _pullCategories(userId);
      await _pullLiabilities(userId);

      SyncTrace.log('PULL  ===== end pullFromFirestore userId=$userId =====');
    } catch (e) {
      'pullFromFirestore failed: $e'.Log('FinancialDataSyncService');
      SyncTrace.log('PULL  FAILED error=$e');
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
      if (!_isAuthenticated) return;
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
      if (!_isAuthenticated) return;
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
      if (!_isAuthenticated) return;
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
      if (!_isAuthenticated) return;
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
      if (!_isAuthenticated) return;
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

  Future<void> _syncPendingLiabilities(String userId) async {
    if (!Hive.isBoxOpen(CcHiveBox.LIABILITY_BOX_NAME)) return;
    Box<LiabilityModel> box;
    try {
      box = Hive.box<LiabilityModel>(CcHiveBox.LIABILITY_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
    for (final model in box.values) {
      if (!_isAuthenticated) return;
      final status = model.syncMetadata.status;
      if (status == SyncStatus.pending || status == SyncStatus.failed) {
        await _syncEntity<LiabilityModel>(
          model: model,
          syncFn: _liabilitySync.syncLiability,
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

  Future<void> _pullLiabilities(String userId) async {
    final box = await _openBox<LiabilityModel>(CcHiveBox.LIABILITY_BOX_NAME);
    if (box == null) return;
    await _pullAndMerge<LiabilityModel>(
      userId: userId,
      collectionName: 'loans',
      box: box,
      fromFirestore: LiabilityModel.fromFirestoreData,
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
    if (!_isAuthenticated) return;
    try {
      final remoteId = await syncFn(model);
      if (remoteId != null) {
        final updated = updateFn(model, remoteId);
        final key = _getLocalId(model);
        if (key != null) await box.put(key, updated);
      }
    } catch (e) {
      // Don't log expected authentication errors during logout
      if (e.toString().contains('User not authenticated')) return;
      'Sync failed for entity: $e'.Log('FinancialDataSyncService');
    }
  }

  Future<void> _pullAndMerge<T>({
    required String userId,
    required String collectionName,
    required Box<T> box,
    required T Function(Map<String, dynamic>, String) fromFirestore,
  }) async {
    if (!_isAuthenticated) return;
    try {
      final remoteData = await _syncService.fetchFromFirestore(
        userId: userId,
        collectionName: collectionName,
      );

      SyncTrace.log(
        'MERGE $collectionName: ${remoteData.length} remote doc(s), '
        '${box.length} local record(s)',
      );

      for (final data in remoteData) {
        final localId = data['localId'] as String;
        final existing = box.get(localId);

        if (existing == null) {
          final model = fromFirestore(data, localId);
          await box.put(localId, model);
          SyncTrace.log('MERGE $collectionName: INSERTED localId=$localId');
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
            SyncTrace.log(
              'MERGE $collectionName: OVERWROTE localId=$localId '
              '(localModAt=$localModifiedAt remoteModAt=$parsedRemote)',
            );
          } else {
            SyncTrace.log(
              'MERGE $collectionName: KEPT LOCAL localId=$localId '
              '(localModAt=$localModifiedAt remoteModAt=$parsedRemote)',
            );
          }
        }
      }
    } catch (e) {
      'Pull failed for $collectionName: $e'.Log('FinancialDataSyncService');
      SyncTrace.log('MERGE $collectionName: FAILED error=$e');
    }
  }

  String? _getLocalId<T>(T model) {
    if (model is WalletHiveModel) return model.id;
    if (model is TransactionModel) return model.id;
    if (model is BudgetLimitModel) return model.id;
    if (model is ReconciliationModel) return model.id;
    if (model is CategoryModel) return model.id;
    if (model is LiabilityModel) return model.id;
    return null;
  }

  DateTime? _getLastModifiedAt<T>(T model) {
    if (model is WalletHiveModel) return model.lastModifiedAt;
    if (model is TransactionModel) return model.lastModifiedAt;
    if (model is BudgetLimitModel) return model.lastModifiedAt;
    if (model is ReconciliationModel) return model.lastModifiedAt;
    if (model is CategoryModel) return model.lastModifiedAt;
    if (model is LiabilityModel) return model.lastModifiedAt;
    return null;
  }
}
