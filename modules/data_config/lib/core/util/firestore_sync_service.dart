import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'sync_trace.dart';

/// Base service for synchronizing data between Hive and Firestore.
///
/// This service provides offline-first synchronization with automatic conflict resolution
/// using last-write-wins strategy based on timestamps.
@lazySingleton
class FirestoreSyncService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Collection path for user-specific data.
  String getUserCollectionPath(String userId, String collectionName) {
    return 'users/$userId/$collectionName';
  }

  /// Syncs a local entity to Firestore.
  ///
  /// Returns the remote document ID if successful, null otherwise.
  Future<String?> syncToFirestore<T>({
    required String userId,
    required String collectionName,
    required String localId,
    required Map<String, dynamic> data,
    String? remoteId,
    DateTime? lastSyncedAt,
  }) async {
    try {
      final collectionPath = getUserCollectionPath(userId, collectionName);
      SyncTrace.log(
        'PUSH  start path=$collectionPath localId=$localId remoteId=$remoteId',
      );
      final collection = _firestore.collection(collectionPath);

      // Add sync metadata to the data
      final syncData = {
        ...data,
        'localId': localId,
        'syncedAt': FieldValue.serverTimestamp(),
        'lastModifiedAt': DateTime.now().toIso8601String(),
      };

      if (remoteId != null) {
        // Update existing document
        final doc = await collection.doc(remoteId).get();
        if (doc.exists) {
          final remoteData = doc.data() as Map<String, dynamic>;
          final remoteModifiedAt = remoteData['lastModifiedAt'] as String?;

          // Conflict resolution: use last-write-wins
          if (remoteModifiedAt != null && lastSyncedAt != null) {
            final remoteTime = DateTime.parse(remoteModifiedAt);
            if (remoteTime.isAfter(lastSyncedAt)) {
              // Remote is newer, don't overwrite
              SyncTrace.log(
                'PUSH  SKIPPED (remote newer) collection=$collectionName '
                'remoteModifiedAt=$remoteModifiedAt lastSyncedAt=$lastSyncedAt',
              );
              return remoteId;
            }
          }

          await collection.doc(remoteId).update(syncData);
          SyncTrace.log(
            'PUSH  updated doc=$remoteId collection=$collectionName',
          );
          return remoteId;
        } else {
          // Document doesn't exist remotely, recreate it under the same id so
          // that repeat pushes stay idempotent instead of duplicating.
          await collection.doc(remoteId).set(syncData);
          SyncTrace.log(
            'PUSH  remoteId pointed at a deleted doc -> recreated '
            'doc=$remoteId collection=$collectionName localId=$localId',
          );
          return remoteId;
        }
      } else {
        // Create new document using the local id as the document id. Using
        // `collection.add()` here would allocate a random auto-id, so every
        // repeated push of the same local record spawned a new duplicate.
        await collection.doc(localId).set(syncData);
        SyncTrace.log(
          'PUSH  created doc=$localId collection=$collectionName '
          'localId=$localId',
        );
        return localId;
      }
    } catch (e) {
      SyncTrace.log('PUSH  FAILED collection=$collectionName error=$e');
      throw SyncException('Failed to sync to Firestore: $e');
    }
  }

  /// Fetches data from Firestore for a user.
  Future<List<Map<String, dynamic>>> fetchFromFirestore({
    required String userId,
    required String collectionName,
  }) async {
    try {
      final collectionPath = getUserCollectionPath(userId, collectionName);
      final snapshot = await _firestore.collection(collectionPath).get();

      final docs = snapshot.docs.map((doc) {
        final data = doc.data();
        data['remoteId'] = doc.id;
        return data;
      }).toList();

      SyncTrace.log(
        'PULL  network-returned docs=${docs.length} path=$collectionPath '
        'localIds=${docs.map((d) => d['localId']).toList()}',
      );
      return docs;
    } catch (e) {
      SyncTrace.log('PULL  FAILED collection=$collectionName error=$e');
      throw SyncException('Failed to fetch from Firestore: $e');
    }
  }

  /// Deletes a document from Firestore.
  Future<void> deleteFromFirestore({
    required String userId,
    required String collectionName,
    required String remoteId,
  }) async {
    try {
      final collectionPath = getUserCollectionPath(userId, collectionName);
      await _firestore.collection(collectionPath).doc(remoteId).delete();
    } catch (e) {
      throw SyncException('Failed to delete from Firestore: $e');
    }
  }

  /// Listens to real-time updates from Firestore.
  Stream<List<Map<String, dynamic>>> streamFromFirestore({
    required String userId,
    required String collectionName,
  }) {
    final collectionPath = getUserCollectionPath(userId, collectionName);
    return _firestore
        .collection(collectionPath)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['remoteId'] = doc.id;
            return data;
          }).toList(),
        );
  }
}

/// Exception thrown when sync operations fail.
class SyncException implements Exception {
  final String message;

  SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}
