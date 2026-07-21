import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:injectable/injectable.dart';

import '../models/transaction_model.dart';

@injectable
class TransactionSyncDataSource {
  final FirestoreSyncService _syncService;
  final SessionContract _session;

  TransactionSyncDataSource(this._syncService, this._session);

  Future<String?> syncTransaction(TransactionModel transaction) async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    final metadata = transaction.syncMetadata;
    return await _syncService.syncToFirestore(
      userId: user.id,
      collectionName: 'transactions',
      localId: transaction.id ?? '',
      data: transaction.toFirestoreData(),
      remoteId: metadata.remoteId,
      lastSyncedAt: metadata.lastSyncedAt,
    );
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return await _syncService.fetchFromFirestore(
      userId: user.id,
      collectionName: 'transactions',
    );
  }

  Future<void> deleteTransaction(String remoteId) async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    await _syncService.deleteFromFirestore(
      userId: user.id,
      collectionName: 'transactions',
      remoteId: remoteId,
    );
  }

  Stream<List<Map<String, dynamic>>> streamTransactions() {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return _syncService.streamFromFirestore(
      userId: user.id,
      collectionName: 'transactions',
    );
  }
}
