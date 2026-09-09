import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

import '../models/liability_model.dart';

@injectable
class LiabilitySyncDatasource {
  final GenericSyncDataSource _delegate;

  LiabilitySyncDatasource(
    FirestoreSyncService syncService,
    SessionContract session,
  ) : _delegate = GenericSyncDataSource(syncService, session, 'loans');

  Future<String?> syncLiability(LiabilityModel liability) => _delegate.sync(
    localId: liability.id,
    data: liability.toFirestoreData(),
    remoteId: liability.syncMetadata.remoteId,
    lastSyncedAt: liability.syncMetadata.lastSyncedAt,
  );

  Future<List<Map<String, dynamic>>> fetchLiabilities() => _delegate.fetch();

  Future<void> deleteLiability(String remoteId) => _delegate.delete(remoteId);

  Stream<List<Map<String, dynamic>>> streamLiabilities() => _delegate.stream();
}
