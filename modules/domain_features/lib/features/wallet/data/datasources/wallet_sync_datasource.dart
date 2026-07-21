import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:injectable/injectable.dart';

import '../models/wallet_hive_model.dart';

/// Data source for synchronizing wallet data with Firestore.
@injectable
class WalletSyncDataSource {
  final FirestoreSyncService _syncService;
  final SessionContract _session;

  WalletSyncDataSource(
    this._syncService,
    this._session,
  );

  /// Syncs a wallet to Firestore.
  Future<String?> syncWallet(WalletHiveModel wallet) async {
    final user = _session.currentUser;
    if (user == null) {
      throw SyncException('User not authenticated');
    }

    final metadata = wallet.syncMetadata;
    return await _syncService.syncToFirestore(
      userId: user.id,
      collectionName: 'wallets',
      localId: wallet.id,
      data: wallet.toFirestoreData(),
      remoteId: metadata.remoteId,
      lastSyncedAt: metadata.lastSyncedAt,
    );
  }

  /// Fetches all wallets from Firestore for the current user.
  Future<List<Map<String, dynamic>>> fetchWallets() async {
    final user = _session.currentUser;
    if (user == null) {
      throw SyncException('User not authenticated');
    }

    return await _syncService.fetchFromFirestore(
      userId: user.id,
      collectionName: 'wallets',
    );
  }

  /// Deletes a wallet from Firestore.
  Future<void> deleteWallet(String remoteId) async {
    final user = _session.currentUser;
    if (user == null) {
      throw SyncException('User not authenticated');
    }

    await _syncService.deleteFromFirestore(
      userId: user.id,
      collectionName: 'wallets',
      remoteId: remoteId,
    );
  }

  /// Listens to real-time wallet updates from Firestore.
  Stream<List<Map<String, dynamic>>> streamWallets() {
    final user = _session.currentUser;
    if (user == null) {
      throw SyncException('User not authenticated');
    }

    return _syncService.streamFromFirestore(
      userId: user.id,
      collectionName: 'wallets',
    );
  }
}
