import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

import '../models/transaction_model.dart';

@injectable
class TransactionSyncDataSource {
  final GenericSyncDataSource _delegate;

  TransactionSyncDataSource(
    FirestoreSyncService syncService,
    SessionContract session,
  ) : _delegate = GenericSyncDataSource(syncService, session, 'transactions');

  Future<String?> syncTransaction(TransactionModel transaction) =>
      _delegate.sync(
        localId: transaction.id ?? '',
        data: transaction.toFirestoreData(),
        remoteId: transaction.syncMetadata.remoteId,
        lastSyncedAt: transaction.syncMetadata.lastSyncedAt,
      );

  Future<List<Map<String, dynamic>>> fetchTransactions() => _delegate.fetch();

  Future<void> deleteTransaction(String remoteId) => _delegate.delete(remoteId);

  Stream<List<Map<String, dynamic>>> streamTransactions() => _delegate.stream();
}
