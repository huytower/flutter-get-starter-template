import 'dart:async';

import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:app_config/data/datasources/local/box/prj_hive_box.dart';
import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:domain_features/core/contracts/financial_refresh_provider.dart';
import 'package:domain_features/core/data/sync/firestore_sync_service.dart';
import 'package:domain_features/features/firestore/enum/logout_block.dart';
import 'package:domain_features/features/firestore/enum/logout_result.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:domain_features/features/firestore/guest_login_prompt_service.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../core/di/di.dart';
import '../../features/budget_limit/data/datasources/budget_limit_sync_datasource.dart';
import '../../features/budget_limit/data/models/budget_limit_model.dart';
import '../../features/category/data/datasources/category_sync_datasource.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/liability/data/datasources/liability_sync_datasource.dart';
import '../../features/liability/data/models/liability_model.dart';
import '../../features/profile/data/datasources/account_settings_sync_datasource.dart';
import '../../features/profile/data/services/account_settings_sync.dart';
import '../../features/reconciliation/data/datasources/reconciliation_sync_datasource.dart';
import '../../features/reconciliation/data/models/reconciliation_model.dart';
import '../../features/transaction/data/datasources/transaction_sync_datasource.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/wallet/data/datasources/wallet_sync_datasource.dart';
import '../../features/wallet/data/models/wallet_hive_model.dart';
import 'pending_cloud_deletes.dart';
import 'pending_record_counter.dart';

export 'enum/logout_block.dart';
export 'enum/logout_result.dart';

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
    this._refresh,
    this._accountSettings,
  );

  final FinancialRefreshProvider _refresh;
  final AccountSettingsSync _accountSettings;

  bool get _hasAuthenticated => _session.currentUser != null;

  String? get _userId => _session.currentUser?.id;

  /// Whether the device currently has internet access — drives the
  /// sync-status indicator. Kept live by [startWatching].
  ///
  /// Starts pessimistic (`false`) and is corrected by [_probeOnline] before
  /// anything destructive (logout / cache clear) consults it. `onStatusChange`
  /// does not emit an initial value, so a device that boots offline would
  /// otherwise report "online" until connectivity actually changed.
  final RxBool hasOnline = false.obs;

  /// Local changes not yet in the cloud (records, queued deletes, account
  /// settings); drives the sync-status icon. Recomputed after every
  /// [syncAll], which every write already fires.
  final RxInt pendingCount = 0.obs;

  /// Whether a push or pull is running — also drives the sync icon. A pull
  /// can take tens of seconds, and [pendingCount] is only recomputed *after* a
  /// sync, so on its own the icon would sit on "synced" during a long pull.
  final RxBool hasSyncing = false.obs;

  /// Number of overlapping sync operations. A plain flag would flicker off
  /// when, say, a connectivity-triggered [syncAll] overlaps a manual pull.
  int _activeSyncOps = 0;

  /// Whether a coalesced push pass is currently running, and whether another
  /// request arrived while it was. Together these let [syncAll] collapse a
  /// burst of write requests into at most one extra pass.
  bool _pushInFlight = false;
  bool _pushQueued = false;
  Future<void>? _pushLoop;

  /// Runs [task] with [hasSyncing] raised, using a counter so overlapping
  /// operations cannot clear the flag while another is still in flight.
  Future<T> _trackSync<T>(Future<T> Function() task) async {
    _activeSyncOps++;
    hasSyncing.value = true;
    try {
      return await task();
    } finally {
      _activeSyncOps--;
      hasSyncing.value = _activeSyncOps > 0;
    }
  }

  // ignore: cancel_subscriptions
  StreamSubscription<InternetStatus>? _connectivitySubscription;

  // ignore: cancel_subscriptions
  StreamSubscription<CcUserEntity?>? _sessionSubscription;
  Future<void>? _accountTransition;
  String? _observedUserId;

  /// Starts watching connectivity in the background and seeds the initial
  /// [pendingCount]. Call once at app boot (mirrors `NotificationService
  /// .ensureInitialized()`); safe to call more than once.
  void startWatching() {
    _connectivitySubscription ??= _connection.onStatusChange.listen((status) {
      final online = status == InternetStatus.connected;
      hasOnline.value = online;
      if (online && pendingCount.value > 0) {
        unawaited(syncAll());
      }
    });
    _sessionSubscription ??= _session.userStream.listen(_handleSessionChange);
    pendingCount.value = _countPending();
    unawaited(
      _probeOnline().then((online) {
        if (online && pendingCount.value > 0) {
          unawaited(syncAll());
        }
      }),
    );
  }

  /// Asks the connectivity checker for the real current state and mirrors it
  /// into [hasOnline]. Fails closed — if the probe itself throws we treat the
  /// device as offline, because every destructive path keys off this value.
  Future<bool> _probeOnline() async {
    try {
      final online = await _connection.hasInternetAccess;
      hasOnline.value = online;
      return online;
    } catch (e) {
      hasOnline.value = false;
      '[LOGOUT_DEBUG] Connectivity probe failed, treating as offline: $e'.Log(
        'FinancialDataSyncService',
      );
      return false;
    }
  }

  /// Serialises [task] behind any in-flight account transition.
  ///
  /// A cache clear must never interleave with a sign-in transition, otherwise
  /// a wipe could land between another user's `pullFromFirestore()` and the
  /// owner bookkeeping that follows it.
  Future<void> _enqueueTransition(Future<void> Function() task) {
    _accountTransition = (_accountTransition ?? Future.value())
        .then((_) => task())
        .catchError((error) {
          'Account transition failed: $error'.Log('FinancialDataSyncService');
        });
    return _accountTransition!;
  }

  /// Observes the session and drives cache transitions.
  ///
  /// The sign-out branch is deliberately **non-destructive**. Firebase can
  /// emit a sign-out for reasons that have nothing to do with the user asking
  /// to leave — token revocation, credential clearing, account removal — and
  /// none of those are gated on [pendingCount]. Deleting the cache here would
  /// throw away unsynced records the user never got the chance to back up.
  ///
  /// The only place a successful, fully-synced logout wipes the cache is
  /// [logoutSafely], which verifies `pendingCount == 0` first. An unsolicited
  /// sign-out therefore only blanks the in-memory state and keeps the records
  /// on disk, ready for the same user to sign back in.
  Future<void> _handleSessionChange(CcUserEntity? user) {
    final nextUserId = user?.id;
    if (nextUserId == null && _observedUserId == null) return Future.value();
    if (nextUserId == _observedUserId) return Future.value();

    return _enqueueTransition(() async {
      if (nextUserId == null) {
        // Signed out without a verified sync — forget the live user, keep the
        // records so they can still be pushed if the same user returns.
        _observedUserId = null;
        await _refresh.releaseAllLoaded();
        return;
      }

      if (_observedUserId != null && _observedUserId != nextUserId) {
        await _clearFinancialCache();
      }
      final previousOwner = PrjAppStorage.instance.financialDataOwnerId;
      await _ensureCacheOwner(nextUserId);
      _observedUserId = nextUserId;
      // A returning account may have local writes that were made while the
      // auth stream was unavailable. Push those records before pulling so a
      // stale cloud snapshot cannot win the merge.
      if (previousOwner == nextUserId) {
        await syncAll();
      }
      // Settings first: the book currency must match before records arrive.
      await _accountSettings.adoptAccount();
      // `pullFromFirestore()` refreshes the loaded controllers itself once the
      // merge completes, so the UI is updated from the post-pull Hive state.
      await pullFromFirestore();
    });
  }

  /// Completes the authenticated account handshake in a deterministic order.
  ///
  /// Guest-owned records are discarded by [_ensureCacheOwner] and are never
  /// uploaded. Records already owned by this Firebase UID are pushed first,
  /// then the cloud state is merged into Hive.
  Future<void> syncAuthenticatedData() {
    return _enqueueTransition(() async {
      final userId = _userId;
      if (userId == null) return;

      final previousOwner = PrjAppStorage.instance.financialDataOwnerId;
      await _ensureCacheOwner(userId);
      _observedUserId = userId;
      if (previousOwner == userId) {
        await syncAll();
      }
      await _accountSettings.adoptAccount();
      await pullFromFirestore();
    });
  }

  Future<void> _ensureCacheOwner(String userId) async {
    final previousOwner = PrjAppStorage.instance.financialDataOwnerId;
    if (previousOwner != userId) {
      // `previousOwner == null` after a logout means the cache now holds the
      // guest account's own records. They have no cloud destination yet, so
      // they cannot be adopted by [userId] — they are cleared and the pull
      // repopulates from Firestore. Log loudly rather than letting a guest's
      // work disappear with no trace.
      await _clearFinancialCache();
    }
    PrjAppStorage.instance.financialDataOwnerId = userId;
    await PrjAppStorage.instance.save();
  }

  /// Box names wired into [_clearFinancialCache].
  ///
  /// `hive_ce` matches a box's registered model by **exact** `Type`
  /// equality, so those two methods cannot iterate [PrjHiveBox.financialBoxes]
  /// generically — the type argument has to be supplied per box. This set is
  /// what makes that wiring auditable: if a seventh financial box is added, the
  /// guard below reports it instead of silently leaving it behind.
  static const Set<String> _typedFinancialBoxes = {
    PrjHiveBox.WALLET_BOX_NAME,
    PrjHiveBox.CATEGORY_BOX_NAME,
    PrjHiveBox.TRANSACTION_BOX_NAME,
    PrjHiveBox.BUDGET_BOX_NAME,
    PrjHiveBox.RECONCILIATION_BOX_NAME,
    PrjHiveBox.LIABILITY_BOX_NAME,
  };

  /// Fails loudly when a financial box has no typed accessor, rather than
  /// letting it be skipped in silence on every logout.
  static void _assertAllFinancialBoxesWired() {
    final unwired = PrjHiveBox.financialBoxes
        .where((name) => !_typedFinancialBoxes.contains(name))
        .toList(growable: false);
    if (unwired.isEmpty) return;
    '⚠️ financial box(es) with no typed accessor — they will never be '
            'cleared on logout: $unwired'
        .Log('FinancialDataSyncService');
  }

  /// Clears one financial box using the model type it was registered with.
  ///
  /// `Hive.box(name)` infers `dynamic`, and `hive_ce` compares `valueType` by
  /// exact equality rather than subtyping, so it throws `HiveError: The box
  /// "wallet" is already open and of type Box<WalletHiveModel>` for every
  /// typed box. The failure is caught per box on purpose: a single throw used
  /// to abort the remaining boxes and the caller still reported success.
  Future<void> _wipeBox<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<T>(boxName).clear();
      } else {
        await Hive.deleteBoxFromDisk(boxName);
      }
    } on HiveError catch (e) {
      'Cache wipe skipped $boxName: $e'.Log('FinancialDataSyncService');
    }
  }

  Future<void> _clearFinancialCache() async {
    _assertAllFinancialBoxesWired();
    await _wipeBox<WalletHiveModel>(PrjHiveBox.WALLET_BOX_NAME);
    await _wipeBox<CategoryModel>(PrjHiveBox.CATEGORY_BOX_NAME);
    await _wipeBox<TransactionModel>(PrjHiveBox.TRANSACTION_BOX_NAME);
    await _wipeBox<BudgetLimitModel>(PrjHiveBox.BUDGET_BOX_NAME);
    await _wipeBox<ReconciliationModel>(PrjHiveBox.RECONCILIATION_BOX_NAME);
    await _wipeBox<LiabilityModel>(PrjHiveBox.LIABILITY_BOX_NAME);
    PrjAppStorage.instance
      ..financialDataOwnerId = null
      ..pendingCloudDeletes = null;
    await _accountSettings.clearLocal(); // also saves the storage
    pendingCount.value = 0;
  }

  /// Whether the user is currently allowed to sign out.
  bool canLogout() {
    final block = logoutBlock;
    return block == null;
  }

  /// Null when sign-out is allowed, otherwise the reason it is blocked.
  /// Surfaced verbatim to the user by the Profile screen.
  ///
  /// Reads [pendingCount] rather than recomputing so an `Obx` in the UI
  /// rebuilds when either connectivity or the unsynced count changes. The
  /// authoritative check happens in [logoutSafely], which re-counts.
  ///
  /// Returns null when there is no session: there is no sign-out to perform, so
  /// connectivity and unsynced records cannot block anything. Both guards below
  /// only make sense for a user who is *about to lose* access to an account —
  /// and the Profile screen already hides the button for guests.
  LogoutBlock? get logoutBlock {
    final online = hasOnline.value;
    final pending = pendingCount.value;
    if (!_hasAuthenticated) {
      return null;
    } else if (!online) {
      return LogoutBlock.offline;
    } else if (pending > 0) {
      return LogoutBlock.pendingSync;
    } else {
      return null;
    }
  }

  /// Runs the full sign-out handshake.
  ///
  /// Probes the real connection, pushes any pending/failed records, and only
  /// then signs out. Reaching the end means `pendingCount == 0` was verified,
  /// i.e. every record already lives in Firestore — so the local cache is then
  /// cleared. Keeping it would only repaint the previous account's balances
  /// into the still-mounted shell, since the app deliberately stays on the
  /// current tab instead of routing to Login.
  ///
  /// The failure paths return *before* signing out and leave the cache
  /// untouched, so an offline or unsynced logout still cannot lose data.
  Future<LogoutResult> logoutSafely() async {
    if (!_hasAuthenticated) {
      // Nothing to end. Signing out again would be a no-op, and running the
      // cache clear would silently destroy a guest's local records — they
      // belong to no account, so there is nothing to protect them from and
      // nowhere to push them to. They stay put until an account signs in.
      return LogoutResult.success;
    }

    // Always trust the probe over the cached Rx value.
    if (!await _probeOnline()) {
      return LogoutResult.offline;
    }

    if (_countPending() > 0) {
      await syncAll();
    }

    if (_countPending() > 0) {
      return LogoutResult.pendingSync;
    }

    await _session.clearSession();

    // Signed out and fully backed up: drop the cache so the next account
    // cannot read it. Serialised against any in-flight session transition, and
    // the refresh leaves the mounted controllers showing a fresh, empty state
    // (WalletLocalDataSource re-seeds Cash + Bank at 0) instead of the
    // previous user's balances.
    await _enqueueTransition(_resetAfterLogout);
    return LogoutResult.success;
  }

  /// Every Firestore collection the app syncs under `users/{uid}/`.
  static const List<String> syncedCollections = [
    'wallets',
    'transactions',
    'budgets',
    'reconciliations',
    'categories',
    'loans',
    AccountSettingsSyncDataSource.collectionName,
  ];

  /// Deletes the signed-in user's synced financial data from Firestore. Runs
  /// right before the Firebase account is deleted (afterwards the client no
  /// longer has permission). Throws when the data could not be deleted, so
  /// the account deletion stops and the user can retry.
  Future<void> deleteCloudData() async {
    final userId = _userId;
    if (userId == null) return;
    await _syncService.deleteAllUserData(
      userId: userId,
      collectionNames: syncedCollections,
    );
  }

  /// Clears local financial data, wipes Hive boxes, and resets all in-memory
  /// state after account deletion, matching the post-logout reset behavior.
  Future<void> handleAccountDeleted() async {
    await _enqueueTransition(_resetAfterLogout);
  }

  /// Blanks the device's financial state after a completed sign-out.
  ///
  /// In-memory release runs first so no frame is ever painted with the
  /// outgoing account's data, then the boxes are wiped, then the controllers
  /// are re-read from the now-empty boxes so the UI the user is looking at
  /// settles on a consistent logged-out state instead of a full-screen loader.
  Future<void> _resetAfterLogout() async {
    await _refresh.releaseAllLoaded();
    await _clearFinancialCache();
    await getIt<GuestLoginPromptService>().resetPromptFlags();
    await _refresh.refreshAllLoaded();
  }

  /// Pushes every pending/failed record to the cloud.
  ///
  /// Repositories call this fire-and-forget after each local write, so a
  /// single user gesture can request it many times in a row (toggling
  /// "full access" alone enables ~19 investment/liability categories, each of
  /// which calls `syncAll()`). Running each request as its own full push means
  /// N overlapping scans of the pending set and N concurrent writers for the
  /// same records. Requests are therefore coalesced: the first caller starts
  /// the run, and every caller arriving while it is in flight shares that same
  /// future instead of starting another. If requests landed while the run was
  /// in flight, one extra pass runs afterwards so records written after their
  /// collection was already scanned are not missed.
  Future<void> syncAll() {
    if (_pushInFlight) {
      _pushQueued = true;
      return _pushLoop ?? Future<void>.value();
    }
    return _pushLoop = _pushDrain();
  }

  /// Loops [_runSyncAll] until no further request arrived during a pass.
  Future<void> _pushDrain() async {
    _pushInFlight = true;
    try {
      do {
        _pushQueued = false;
        await _trackSync(_runSyncAll);
      } while (_pushQueued);
    } finally {
      _pushInFlight = false;
      _pushLoop = null;
    }
  }

  Future<void> _runSyncAll() async {
    try {
      final userId = _userId;
      if (userId != null && await _connection.hasInternetAccess) {
        await PendingCloudDeletes.flush(_syncService, userId);
        await _syncPendingWallets(userId);
        await _syncPendingTransactions(userId);
        await _syncPendingBudgets(userId);
        await _syncPendingReconciliations(userId);
        await _syncPendingCategories(userId);
        await _syncPendingLiabilities(userId);
        await _accountSettings.push();
      }
    } catch (e) {
      'syncAll failed: $e'.Log('FinancialDataSyncService');
    } finally {
      pendingCount.value = _countPending();
    }
  }

  /// Unsynced financial records plus the account settings, if changed.
  int _countPending() =>
      PendingRecordCounter.count() + _accountSettings.pendingCount;

  /// Merges the current user's Firestore state into Hive and refreshes the UI.
  ///
  /// Tracked by [hasSyncing]; the work itself lives in [_runPull].
  Future<void> pullFromFirestore() => _trackSync(_runPull);

  Future<void> _runPull() async {
    try {
      final userId = _userId;
      if (userId == null) {
        return;
      }
      if (!await _connection.hasInternetAccess) {
        return;
      }

      await _pullWallets(userId);
      await _pullTransactions(userId);
      await _pullBudgets(userId);
      await _pullReconciliations(userId);
      await _pullCategories(userId);
      await _pullLiabilities(userId);

      // The pull mutated the Hive boxes, so anything already rendered from
      // them is now stale. Refreshing here (rather than at each call site)
      // makes "UI always mirrors Hive after a pull" an invariant of the pull
      // itself — otherwise correctness depended on which caller remembered to
      // do it, and the bridge's `syncAuthenticatedData()` path silently left
      // the wallet/budget screens showing pre-pull data.
      await _refresh.refreshAllLoaded();
    } catch (e) {
      'pullFromFirestore failed: $e'.Log('FinancialDataSyncService');
    }
  }

  Future<void> _syncPendingWallets(String userId) async {
    if (!Hive.isBoxOpen(PrjHiveBox.WALLET_BOX_NAME)) return;
    Box<WalletHiveModel> box;
    try {
      box = Hive.box<WalletHiveModel>(PrjHiveBox.WALLET_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
    for (final model in box.values) {
      if (!_hasAuthenticated) return;
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
    if (!Hive.isBoxOpen(PrjHiveBox.TRANSACTION_BOX_NAME)) return;
    Box<TransactionModel> box;
    try {
      box = Hive.box<TransactionModel>(PrjHiveBox.TRANSACTION_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
    for (final model in box.values) {
      if (!_hasAuthenticated) return;
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
    if (!Hive.isBoxOpen(PrjHiveBox.BUDGET_BOX_NAME)) return;
    Box<BudgetLimitModel> box;
    try {
      box = Hive.box<BudgetLimitModel>(PrjHiveBox.BUDGET_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
    for (final model in box.values) {
      if (!_hasAuthenticated) return;
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
    if (!Hive.isBoxOpen(PrjHiveBox.RECONCILIATION_BOX_NAME)) return;
    Box<ReconciliationModel> box;
    try {
      box = Hive.box<ReconciliationModel>(PrjHiveBox.RECONCILIATION_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
    for (final model in box.values) {
      if (!_hasAuthenticated) return;
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
    if (!Hive.isBoxOpen(PrjHiveBox.CATEGORY_BOX_NAME)) return;
    Box<CategoryModel> box;
    try {
      box = Hive.box<CategoryModel>(PrjHiveBox.CATEGORY_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
    for (final model in box.values) {
      if (!_hasAuthenticated) return;
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
    if (!Hive.isBoxOpen(PrjHiveBox.LIABILITY_BOX_NAME)) return;
    Box<LiabilityModel> box;
    try {
      box = Hive.box<LiabilityModel>(PrjHiveBox.LIABILITY_BOX_NAME);
    } on HiveError catch (e) {
      if (e.message.contains('already open')) return;
      rethrow;
    }
    for (final model in box.values) {
      if (!_hasAuthenticated) return;
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
    final box = await _openBox<WalletHiveModel>(PrjHiveBox.WALLET_BOX_NAME);
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
      PrjHiveBox.TRANSACTION_BOX_NAME,
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
    final box = await _openBox<BudgetLimitModel>(PrjHiveBox.BUDGET_BOX_NAME);
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
      PrjHiveBox.RECONCILIATION_BOX_NAME,
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
    final box = await _openBox<CategoryModel>(PrjHiveBox.CATEGORY_BOX_NAME);
    if (box == null) return;
    await _pullAndMerge<CategoryModel>(
      userId: userId,
      collectionName: 'categories',
      box: box,
      fromFirestore: CategoryModel.fromFirestoreData,
    );
  }

  Future<void> _pullLiabilities(String userId) async {
    final box = await _openBox<LiabilityModel>(PrjHiveBox.LIABILITY_BOX_NAME);
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
    if (!_hasAuthenticated) return;
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

      // Persist the failure. Without this the record stays `pending`
      // forever, `_countPending()` never drops to zero, and the guarded
      // logout would lock the user out of their own account.
      final key = _getLocalId(model);
      if (key != null) {
        await box.put(key, _withSyncStatus(model, SyncStatus.failed));
      }
    }
  }

  Future<void> _pullAndMerge<T>({
    required String userId,
    required String collectionName,
    required Box<T> box,
    required T Function(Map<String, dynamic>, String) fromFirestore,
  }) async {
    if (!_hasAuthenticated) return;
    try {
      final remoteData = await _syncService.fetchFromFirestore(
        userId: userId,
        collectionName: collectionName,
      );

      for (final data in remoteData) {
        final localId = data['localId'] as String;
        final existing = box.get(localId);
        // Deleted here, cloud delete still queued: never pull it back.
        if (PendingCloudDeletes.has(collectionName, localId)) continue;
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
    if (model is LiabilityModel) return model.id;
    return null;
  }

  /// Returns [model] with its sync status replaced. Used to persist a
  /// terminal `failed` so a record that can never upload stops spinning and
  /// becomes discardable instead of blocking sign-out forever.
  ///
  /// The `errorMessage` is intentionally not persisted — none of the six Hive
  /// models carry a field for it, and adding one to all of them is a schema
  /// change out of proportion to its value. It is logged instead.
  T _withSyncStatus<T>(T model, SyncStatus status) {
    if (model is WalletHiveModel) {
      return model.copyWithSyncMetadata(
            model.syncMetadata.copyWith(status: status),
          )
          as T;
    }
    if (model is TransactionModel) {
      return model.copyWithSyncMetadata(
            model.syncMetadata.copyWith(status: status),
          )
          as T;
    }
    if (model is BudgetLimitModel) {
      return model.copyWithSyncMetadata(
            model.syncMetadata.copyWith(status: status),
          )
          as T;
    }
    if (model is ReconciliationModel) {
      return model.copyWithSyncMetadata(
            model.syncMetadata.copyWith(status: status),
          )
          as T;
    }
    if (model is CategoryModel) {
      return model.copyWithSyncMetadata(
            model.syncMetadata.copyWith(status: status),
          )
          as T;
    }
    if (model is LiabilityModel) {
      return model.copyWithSyncMetadata(
            model.syncMetadata.copyWith(status: status),
          )
          as T;
    }
    return model;
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
