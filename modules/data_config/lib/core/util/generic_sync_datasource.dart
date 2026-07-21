import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';

class GenericSyncDataSource {
  final FirestoreSyncService _syncService;
  final SessionContract _session;
  final String collectionName;

  GenericSyncDataSource(
    this._syncService,
    this._session,
    this.collectionName,
  );

  Future<String?> sync({
    required String localId,
    required Map<String, dynamic> data,
    String? remoteId,
    DateTime? lastSyncedAt,
  }) async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return await _syncService.syncToFirestore(
      userId: user.id,
      collectionName: collectionName,
      localId: localId,
      data: data,
      remoteId: remoteId,
      lastSyncedAt: lastSyncedAt,
    );
  }

  Future<List<Map<String, dynamic>>> fetch() async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return await _syncService.fetchFromFirestore(
      userId: user.id,
      collectionName: collectionName,
    );
  }

  Future<void> delete(String remoteId) async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    await _syncService.deleteFromFirestore(
      userId: user.id,
      collectionName: collectionName,
      remoteId: remoteId,
    );
  }

  Stream<List<Map<String, dynamic>>> stream() {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return _syncService.streamFromFirestore(
      userId: user.id,
      collectionName: collectionName,
    );
  }
}
