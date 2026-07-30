import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

import '../models/reconciliation_model.dart';

@injectable
class ReconciliationSyncDataSource {
  final GenericSyncDataSource _delegate;

  ReconciliationSyncDataSource(
    FirestoreSyncService syncService,
    SessionContract session,
  ) : _delegate = GenericSyncDataSource(
        syncService,
        session,
        'reconciliations',
      );

  Future<String?> syncReconciliation(ReconciliationModel reconciliation) =>
      _delegate.sync(
        localId: reconciliation.id,
        data: reconciliation.toFirestoreData(),
        remoteId: reconciliation.syncMetadata.remoteId,
        lastSyncedAt: reconciliation.syncMetadata.lastSyncedAt,
      );

  Future<List<Map<String, dynamic>>> fetchReconciliations() =>
      _delegate.fetch();

  Future<void> deleteReconciliation(String remoteId) =>
      _delegate.delete(remoteId);

  Stream<List<Map<String, dynamic>>> streamReconciliations() =>
      _delegate.stream();
}
