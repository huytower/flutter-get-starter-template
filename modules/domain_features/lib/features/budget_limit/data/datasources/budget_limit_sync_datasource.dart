import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:injectable/injectable.dart';

import '../models/budget_limit_model.dart';

@injectable
class BudgetLimitSyncDataSource {
  final FirestoreSyncService _syncService;
  final SessionContract _session;

  BudgetLimitSyncDataSource(this._syncService, this._session);

  Future<String?> syncBudget(BudgetLimitModel budget) async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    final metadata = budget.syncMetadata;
    return await _syncService.syncToFirestore(
      userId: user.id,
      collectionName: 'budgets',
      localId: budget.id,
      data: budget.toFirestoreData(),
      remoteId: metadata.remoteId,
      lastSyncedAt: metadata.lastSyncedAt,
    );
  }

  Future<List<Map<String, dynamic>>> fetchBudgets() async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return await _syncService.fetchFromFirestore(
      userId: user.id,
      collectionName: 'budgets',
    );
  }

  Future<void> deleteBudget(String remoteId) async {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    await _syncService.deleteFromFirestore(
      userId: user.id,
      collectionName: 'budgets',
      remoteId: remoteId,
    );
  }

  Stream<List<Map<String, dynamic>>> streamBudgets() {
    final user = _session.currentUser;
    if (user == null) throw SyncException('User not authenticated');

    return _syncService.streamFromFirestore(
      userId: user.id,
      collectionName: 'budgets',
    );
  }
}
