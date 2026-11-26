import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:domain_features/core/data/sync/firestore_sync_service.dart';

/// Deletions that still have to reach Firestore.
///
/// A delete removes the record from the device at once and queues its cloud
/// document here (persisted in [PrjAppStorage.pendingCloudDeletes]). The next
/// `syncAll()` that runs online deletes the queued documents and drops them
/// from the queue; offline they wait. Until a document is gone from the cloud
/// the pull skips it ([has]), so a deleted record can never come back, and
/// the queue counts as pending (sync badge, logout guard).
abstract final class PendingCloudDeletes {
  static PrjAppStorage get _storage => PrjAppStorage.instance;

  static List<String> get _queue => _storage.pendingCloudDeletes ?? const [];

  static String _key(String collection, String documentId) =>
      '$collection/$documentId';

  /// Queues the cloud documents of a deleted record. Pass every id the record
  /// may be stored under (its local id and, for older records, its remote id).
  static Future<void> add(
    String collection,
    Iterable<String?> documentIds,
  ) async {
    final keys = {
      ..._queue,
      for (final id in documentIds)
        if (id != null && id.isNotEmpty) _key(collection, id),
    };
    _storage.pendingCloudDeletes = keys.toList();
    await _storage.save();
  }

  /// Whether [documentId] in [collection] is deleted locally and must not be
  /// pulled back.
  static bool has(String collection, String? documentId) =>
      documentId != null && _queue.contains(_key(collection, documentId));

  static int get count => _queue.length;

  /// Deletes every queued document of [userId] from Firestore; each success
  /// leaves the queue. Stops at the first failure (offline): the rest are
  /// retried by the next sync.
  static Future<void> flush(FirestoreSyncService cloud, String userId) async {
    for (final key in List.of(_queue)) {
      final slash = key.indexOf('/');
      try {
        await cloud.deleteFromFirestore(
          userId: userId,
          collectionName: key.substring(0, slash),
          remoteId: key.substring(slash + 1),
        );
      } catch (e) {
        'Cloud delete deferred ($key): $e'.Log('PendingCloudDeletes');
        return;
      }
      _storage.pendingCloudDeletes = List.of(_queue)..remove(key);
      await _storage.save();
    }
  }

  /// Forgets the queue (the device changed owner; the data is gone anyway).
  static Future<void> clear() async {
    _storage.pendingCloudDeletes = null;
    await _storage.save();
  }
}
