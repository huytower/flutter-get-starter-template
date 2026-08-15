import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

import '../models/transaction_template_model.dart';

@injectable
class TransactionTemplateSyncDataSource {
  final GenericSyncDataSource _delegate;

  TransactionTemplateSyncDataSource(
    FirestoreSyncService syncService,
    SessionContract session,
  ) : _delegate = GenericSyncDataSource(
        syncService,
        session,
        'transaction_templates',
      );

  Future<String?> syncTemplate(TransactionTemplateModel template) =>
      _delegate.sync(
        localId: template.id,
        data: template.toFirestoreData(),
        remoteId: template.syncMetadata.remoteId,
        lastSyncedAt: template.syncMetadata.lastSyncedAt,
      );

  Future<List<Map<String, dynamic>>> fetchTemplates() => _delegate.fetch();

  Future<void> deleteTemplate(String remoteId) => _delegate.delete(remoteId);

  Stream<List<Map<String, dynamic>>> streamTemplates() => _delegate.stream();
}
