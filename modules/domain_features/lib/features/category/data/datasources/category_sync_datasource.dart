import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:injectable/injectable.dart';

import '../models/category_model.dart';

@injectable
class CategorySyncDataSource {
  final FirestoreSyncService _syncService;
  final SessionContract _session;

  CategorySyncDataSource(this._syncService, this._session);

  Future<String?> syncCategory(CategoryModel category) async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    final metadata = category.syncMetadata;
    return await _syncService.syncToFirestore(
      userId: user.id,
      collectionName: 'categories',
      localId: category.id,
      data: category.toFirestoreData(),
      remoteId: metadata.remoteId,
      lastSyncedAt: metadata.lastSyncedAt,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return await _syncService.fetchFromFirestore(
      userId: user.id,
      collectionName: 'categories',
    );
  }

  Future<void> deleteCategory(String remoteId) async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    await _syncService.deleteFromFirestore(
      userId: user.id,
      collectionName: 'categories',
      remoteId: remoteId,
    );
  }

  Stream<List<Map<String, dynamic>>> streamCategories() {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return _syncService.streamFromFirestore(
      userId: user.id,
      collectionName: 'categories',
    );
  }
}
