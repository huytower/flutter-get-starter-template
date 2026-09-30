import 'dart:async';

import 'package:app_config/data/datasource/local/box/app_storage/cc_app_storage.dart';
import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
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
import 'enum/logout_block.dart';
import 'enum/logout_result.dart';
import 'enum/sync_status.dart';

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
  );

  bool get _isAuthenticated => _session.currentUser != null;

  String? get _userId => _session.currentUser?.id;

  /// Whether the device currently has internet access — drives the
  /// sync-status indicator. Kept live by [startWatching].
  ///
  /// Starts pessimistic (`false`) and is corrected by [_probeOnline] before
  /// anything destructive (logout / cache clear) consults it. `onStatusChange`
  /// does not emit an initial value, so a device that boots offline would
  /// otherwise report "online" until connectivity actually changed.
  final RxBool isOnline = false.obs;

  /// Count of locally-stored records not yet backed up to Cloud (across all
  /// synced entity types) — also drives the sync-status icon. Recomputed
  /// after every [syncAll] call, so it stays fresh automatically since every
  /// write-repository already fires `syncAll()` after each local write.
  final RxInt pendingCount = 0.obs;

  /// Whether a push or pull is currently running — also drives the
  /// sync-status icon. A pull across six collections can run for tens of
  /// seconds (see the `MERGE` trace volume), which is exactly when the user
  /// needs to be told the app is working rather than idle.
  ///
  /// [pendingCount] alone cannot express this: it is only recomputed *after* a
  /// sync completes, so it reads `0` for the whole duration of a clean pull
  /// and the indicator would sit on "synced" while thousands of records merge.
  final RxBool isSyncing = false.obs;

  /// Number of overlapping sync operations. A plain flag would flicker off
  /// when, say, a connectivity-triggered [syncAll] overlaps a manual pull.
  int _activeSyncOps = 0;

  /// Runs [task] with [isSyncing] raised, using a counter so overlapping
  /// operations cannot clear the flag while another is still in flight.
  Future<T> _trackSync<T>(Future<T> Function() task) async {
    _activeSyncOps++;
    isSyncing.value = true;
    try {
      return await task();
    } finally {
      _activeSyncOps--;
      isSyncing.value = _activeSyncOps > 0;
    }
  }

  StreamSubscription<InternetStatus>? _connectivitySubscription;
  StreamSubscription<CcUserEntity?>? _sessionSubscription;
  Future<void>? _accountTransition;
  String? _observedUserId;

  /// Starts watching connectivity in the background and seeds the initial
  /// [pendingCount]. Call once at app boot (mirrors `NotificationService
  /// .init()`); safe to call more than once.
  void startWatching() {
    _connectivitySubscription ??= _connection.onStatusChange.listen((status) {
      final online = status == InternetStatus.connected;
      isOnline.value = online;
      if (online && pendingCount.value > 0) {
        '[LOGOUT_DEBUG] Connectivity restored — auto-triggering syncAll() for ${pendingCount.value} pending records'
            .Log('FinancialDataSyncService');
        unawaited(syncAll());
      }
    });
    _sessionSubscription ??= _session.userStream.listen(_handleSessionChange);
    pendingCount.value = _countPending();
    unawaited(
      _probeOnline().then((online) {
        if (online && pendingCount.value > 0) {
          '[LOGOUT_DEBUG] Initial online probe succeeded — auto-triggering syncAll() for ${pendingCount.value} pending records'
              .Log('FinancialDataSyncService');
          unawaited(syncAll());
        }
      }),
    );
    SyncTrace.log(
      'WATCH  startWatching() online=${isOnline.value} '
      'pendingCount=${pendingCount.value} authed=${_isAuthenticated}',
    );
  }

  /// Asks the connectivity checker for the real current state and mirrors it
  /// into [isOnline]. Fails closed — if the probe itself throws we treat the
  /// device as offline, because every destructive path keys off this value.
  Future<bool> _probeOnline() async {
    try {
      final online = await _connection.hasInternetAccess;
      isOnline.value = online;
      '[LOGOUT_DEBUG] _probeOnline result=$online'.Log(
        'FinancialDataSyncService',
      );
      return online;
    } catch (e) {
      isOnline.value = false;
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
        SyncTrace.log(
          'SESSION signed out — cache kept '
          'owner=${CcAppStorage.instance.financialDataOwnerId} '
          'pending=${pendingCount.value}',
        );
        await _releaseLoadedControllers();
        return;
      }

      if (_observedUserId != null && _observedUserId != nextUserId) {
        await _clearFinancialCache();
      }
      await _ensureCacheOwner(nextUserId);
      _observedUserId = nextUserId;
      // `pullFromFirestore()` refreshes the loaded controllers itself once the
      // merge completes, so the UI is updated from the post-pull Hive state.
      await pullFromFirestore();
    });
  }

  Future<void> _ensureCacheOwner(String userId) async {
    final previousOwner = CcAppStorage.instance.financialDataOwnerId;
    if (previousOwner != userId) {
      // `previousOwner == null` after a logout means the cache now holds the
      // guest account's own records. They have no cloud destination yet, so
      // they cannot be adopted by [userId] — they are cleared and the pull
      // repopulates from Firestore. Log loudly rather than letting a guest's
      // work disappear with no trace.
      final orphaned = previousOwner == null ? _countPending() : 0;
      if (orphaned > 0) {
        SyncTrace.log(
          'CACHE  discarding $orphaned guest record(s) created while signed '
          'out — no owner to sync them to before $userId signs in',
        );
      }
      await _clearFinancialCache();
    }
    CcAppStorage.instance.financialDataOwnerId = userId;
    await CcAppStorage.instance.save();
  }

  /// Box names wired into [_clearFinancialCache] / [_forEachFinancialBox].
  ///
  /// `hive_ce` matches a box's registered model by **exact** `Type`
  /// equality, so those two methods cannot iterate [CcHiveBox.financialBoxes]
  /// generically — the type argument has to be supplied per box. This set is
  /// what makes that wiring auditable: if a seventh financial box is added, the
  /// guard below reports it instead of silently leaving it behind.
  static const Set<String> _typedFinancialBoxes = {
    CcHiveBox.WALLET_BOX_NAME,
    CcHiveBox.CATEGORY_BOX_NAME,
    CcHiveBox.TRANSACTION_BOX_NAME,
    CcHiveBox.BUDGET_BOX_NAME,
    CcHiveBox.RECONCILIATION_BOX_NAME,
    CcHiveBox.LIABILITY_BOX_NAME,
  };

  /// Fails loudly when a financial box has no typed accessor, rather than
  /// letting it be skipped in silence on every logout.
  static void _assertAllFinancialBoxesWired() {
    final unwired = CcHiveBox.financialBoxes
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

  /// Applies [action] to every open financial box, supplying the right model
  /// type when fetching each one. Closed boxes are skipped, and a box that
  /// cannot be fetched is reported rather than aborting the rest.
  ///
  /// The callback receives the box as `Box<dynamic>` — only the static type is
  /// erased, the underlying object is still the correctly typed box, so
  /// `values` and `delete` behave normally.
  Future<void> _forEachFinancialBox(
    Future<void> Function(String boxName, Box<dynamic> box) action,
  ) async {
    Future<void> run<T>(String boxName) async {
      if (!Hive.isBoxOpen(boxName)) return;
      try {
        await action(boxName, Hive.box<T>(boxName));
      } on HiveError catch (e) {
        'Financial box task skipped $boxName: $e'.Log(
          'FinancialDataSyncService',
        );
      }
    }

    await run<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);
    await run<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME);
    await run<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME);
    await run<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME);
    await run<ReconciliationModel>(CcHiveBox.RECONCILIATION_BOX_NAME);
    await run<LiabilityModel>(CcHiveBox.LIABILITY_BOX_NAME);
  }

  Future<void> _clearFinancialCache() async {
    _assertAllFinancialBoxesWired();
    await _wipeBox<WalletHiveModel>(CcHiveBox.WALLET_BOX_NAME);
    await _wipeBox<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME);
    await _wipeBox<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME);
    await _wipeBox<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME);
    await _wipeBox<ReconciliationModel>(CcHiveBox.RECONCILIATION_BOX_NAME);
    await _wipeBox<LiabilityModel>(CcHiveBox.LIABILITY_BOX_NAME);
    CcAppStorage.instance.financialDataOwnerId = null;
    await CcAppStorage.instance.save();
    pendingCount.value = 0;
  }

  /// Re-reads every already-registered screen controller from the freshly
  /// merged Hive state.
  ///
  /// Runs with `showLoading: false` — a pull finishes on a background task, so
  /// replacing a screen the user is currently looking at with a full-screen
  /// loader (only to repaint it a moment later with the same data) is a
  /// regression, not a refresh. Callers that want visible loading state pass
  /// it themselves via their own pull-to-refresh handlers.
  ///
  /// Each controller is refreshed exactly once, and only when it is actually
  /// mounted.
  ///
  /// [BudgetAllocationController.loadAll] already calls
  /// [WalletController.loadWallets] internally, so the wallet controller is
  /// only refreshed directly when the allocation controller is absent — the
  /// standalone case the `refreshTab` fallback registers. Doing both
  /// unconditionally re-read the same Hive box twice per pull.
  ///
  /// [TransactionController.loadWallets] is a different controller with its
  /// own `RxList` and no loading flag, so it is always refreshed alongside
  /// [TransactionController.refreshWalletTotal].
  Future<void> _refreshLoadedControllers() async {
    if (Get.isRegistered<TransactionController>()) {
      final transaction = Get.find<TransactionController>();
      await Future.wait([
        transaction.refreshWalletTotal(),
        transaction.loadWallets(),
      ]);
    }
    if (Get.isRegistered<BudgetAllocationController>()) {
      await Get.find<BudgetAllocationController>().loadAll(showLoading: false);
    } else if (Get.isRegistered<WalletController>()) {
      await Get.find<WalletController>().loadWallets(showLoading: false);
    }
  }

  /// Blanks the in-memory financial state on sign-out.
  ///
  /// The GetX controllers are `@lazySingleton` and are never disposed, so
  /// without this the previous user's records stay live in their `RxList`s for
  /// the whole unauthenticated window.
  ///
  /// This only clears what is currently rendered. On its own it cannot hold —
  /// any later `loadAll()` re-reads the Hive boxes and repopulates from disk —
  /// so it is always paired with either a cache clear ([_resetAfterLogout]) or
  /// the intention to keep the records for a returning user. Everything else
  /// derived (`borrowBalance`, `lendBalance`, `insights`, budgets) is recomputed
  /// by [_refreshLoadedControllers] from the same post-reset read.
  Future<void> _releaseLoadedControllers() async {
    try {
      if (Get.isRegistered<WalletController>()) {
        Get.find<WalletController>().wallets.clear();
      }
      if (Get.isRegistered<BudgetAllocationController>()) {
        Get.find<BudgetAllocationController>().liabilityBalances.clear();
      }
    } catch (e) {
      'Failed to release in-memory controllers: $e'.Log(
        'FinancialDataSyncService',
      );
    }
  }

  /// Whether the user is currently allowed to sign out.
  bool canLogout() {
    final block = logoutBlock;
    final allowed = block == null;
    '[LOGOUT_DEBUG] canLogout() called -> allowed=$allowed (block=$block) | isOnline=${isOnline.value} | pendingCount=${pendingCount.value}'
        .Log('FinancialDataSyncService');
    return allowed;
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
    final online = isOnline.value;
    final pending = pendingCount.value;
    LogoutBlock? block;
    if (!_isAuthenticated) {
      block = null;
    } else if (!online) {
      block = LogoutBlock.offline;
    } else if (pending > 0) {
      block = LogoutBlock.pendingSync;
    } else {
      block = null;
    }
    '[LOGOUT_DEBUG] logoutBlock getter evaluated -> block=$block | authed=$_isAuthenticated | isOnline=$online | pendingCount=$pending'
        .Log('FinancialDataSyncService');
    return block;
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
    if (!_isAuthenticated) {
      // Nothing to end. Signing out again would be a no-op, and running the
      // cache clear would silently destroy a guest's local records — they
      // belong to no account, so there is nothing to protect them from and
      // nowhere to push them to. They stay put until an account signs in.
      SyncTrace.log(
        'LOGOUT no-op — already signed out '
        'pending=${_countPending()} left untouched',
      );
      return LogoutResult.success;
    }

    // Always trust the probe over the cached Rx value.
    if (!await _probeOnline()) {
      SyncTrace.log('LOGOUT blocked — offline');
      return LogoutResult.offline;
    }

    if (_countPending() > 0) {
      await syncAll();
    }

    if (_countPending() > 0) {
      final remaining = _countPending();
      SyncTrace.log('LOGOUT blocked — $remaining record(s) still unsynced');
      return LogoutResult.pendingSync;
    }

    await _session.clearSession();

    // Signed out and fully backed up: drop the cache so the next account
    // cannot read it. Serialised against any in-flight session transition, and
    // the refresh leaves the mounted controllers showing a fresh, empty state
    // (WalletLocalDataSource re-seeds Cash + Bank at 0) instead of the
    // previous user's balances.
    final owner = CcAppStorage.instance.financialDataOwnerId;
    await _enqueueTransition(_resetAfterLogout);
    SyncTrace.log('LOGOUT completed — cache cleared (previous owner=$owner)');
    return LogoutResult.success;
  }

  /// Blanks the device's financial state after a completed sign-out.
  ///
  /// In-memory release runs first so no frame is ever painted with the
  /// outgoing account's data, then the boxes are wiped, then the controllers
  /// are re-read from the now-empty boxes so the UI the user is looking at
  /// settles on a consistent logged-out state instead of a full-screen loader.
  Future<void> _resetAfterLogout() async {
    await _releaseLoadedControllers();
    await _clearFinancialCache();
    await _refreshLoadedControllers();
  }

  /// Pushes every pending/failed record to the cloud.
  ///
  /// Tracked by [isSyncing]; the work itself lives in [_runSyncAll].
  Future<void> syncAll() => _trackSync(_runSyncAll);

  Future<void> _runSyncAll() async {
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
    final walletPending = _countPendingInBox<WalletHiveModel>(
      CcHiveBox.WALLET_BOX_NAME,
      (m) => m.syncMetadata.status,
    );
    final txPending = _countPendingInBox<TransactionModel>(
      CcHiveBox.TRANSACTION_BOX_NAME,
      (m) => m.syncMetadata.status,
    );
    final budgetPending = _countPendingInBox<BudgetLimitModel>(
      CcHiveBox.BUDGET_BOX_NAME,
      (m) => m.syncMetadata.status,
    );
    final reconPending = _countPendingInBox<ReconciliationModel>(
      CcHiveBox.RECONCILIATION_BOX_NAME,
      (m) => m.syncMetadata.status,
    );
    final catPending = _countPendingInBox<CategoryModel>(
      CcHiveBox.CATEGORY_BOX_NAME,
      (m) => m.syncMetadata.status,
    );
    final liabilityPending = _countPendingInBox<LiabilityModel>(
      CcHiveBox.LIABILITY_BOX_NAME,
      (m) => m.syncMetadata.status,
    );
    final total =
        walletPending +
        txPending +
        budgetPending +
        reconPending +
        catPending +
        liabilityPending;
    '[LOGOUT_DEBUG] _countPending() evaluated -> total=$total (wallet=$walletPending, tx=$txPending, budget=$budgetPending, recon=$reconPending, cat=$catPending, liability=$liabilityPending)'
        .Log('FinancialDataSyncService');
    return total;
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

  /// Merges the current user's Firestore state into Hive and refreshes the UI.
  ///
  /// Tracked by [isSyncing]; the work itself lives in [_runPull].
  Future<void> pullFromFirestore() => _trackSync(_runPull);

  Future<void> _runPull() async {
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

      // The pull mutated the Hive boxes, so anything already rendered from
      // them is now stale. Refreshing here (rather than at each call site)
      // makes "UI always mirrors Hive after a pull" an invariant of the pull
      // itself — otherwise correctness depended on which caller remembered to
      // do it, and the bridge's `syncAuthenticatedData()` path silently left
      // the wallet/budget screens showing pre-pull data.
      await _refreshLoadedControllers();
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

      // Persist the failure. Without this the record stays `pending`
      // forever, `_countPending()` never drops to zero, and the guarded
      // logout would lock the user out of their own account.
      final key = _getLocalId(model);
      if (key != null) {
        await box.put(key, _withSyncStatus(model, SyncStatus.failed));
      }
      SyncTrace.log('PUSH  marked FAILED localId=$key error=$e');
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

  /// Whether this record still needs to reach the cloud. Mirrors the
  /// `_countPendingInBox` filter so the two can never disagree.
  bool _isUnsynced<T>(T model) {
    SyncStatus? statusOf(T m) {
      if (m is WalletHiveModel) return m.syncMetadata.status;
      if (m is TransactionModel) return m.syncMetadata.status;
      if (m is BudgetLimitModel) return m.syncMetadata.status;
      if (m is ReconciliationModel) return m.syncMetadata.status;
      if (m is CategoryModel) return m.syncMetadata.status;
      if (m is LiabilityModel) return m.syncMetadata.status;
      return null;
    }

    final status = statusOf(model);
    return status == SyncStatus.pending || status == SyncStatus.failed;
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
