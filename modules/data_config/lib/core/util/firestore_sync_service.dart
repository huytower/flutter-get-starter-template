import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

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
              return remoteId;
            }
          }
          
          await collection.doc(remoteId).update(syncData);
          return remoteId;
        } else {
          // Document doesn't exist remotely, create it
          final docRef = await collection.add(syncData);
          return docRef.id;
        }
      } else {
        // Create new document
        final docRef = await collection.add(syncData);
        return docRef.id;
      }
    } catch (e) {
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
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['remoteId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
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
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['remoteId'] = doc.id;
              return data;
            }).toList());
  }
}

/// Exception thrown when sync operations fail.
class SyncException implements Exception {
  final String message;
  SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}
