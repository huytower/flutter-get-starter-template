import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

import '../models/category_model.dart';

@injectable
class CategorySyncDataSource {
  final GenericSyncDataSource _delegate;

  CategorySyncDataSource(
    FirestoreSyncService syncService,
    SessionContract session,
  ) : _delegate = GenericSyncDataSource(syncService, session, 'categories');

  Future<String?> syncCategory(CategoryModel category) => _delegate.sync(
    localId: category.id,
    data: category.toFirestoreData(),
    remoteId: category.syncMetadata.remoteId,
    lastSyncedAt: category.syncMetadata.lastSyncedAt,
  );

  Future<List<Map<String, dynamic>>> fetchCategories() => _delegate.fetch();

  Future<void> deleteCategory(String remoteId) => _delegate.delete(remoteId);

  Stream<List<Map<String, dynamic>>> streamCategories() => _delegate.stream();
}
