import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

import '../models/budget_limit_model.dart';

@injectable
class BudgetLimitSyncDataSource {
  final GenericSyncDataSource _delegate;

  BudgetLimitSyncDataSource(
    FirestoreSyncService syncService,
    SessionContract session,
  ) : _delegate = GenericSyncDataSource(syncService, session, 'budgets');

  Future<String?> syncBudget(BudgetLimitModel budget) => _delegate.sync(
        localId: budget.id,
        data: budget.toFirestoreData(),
        remoteId: budget.syncMetadata.remoteId,
        lastSyncedAt: budget.syncMetadata.lastSyncedAt,
      );

  Future<List<Map<String, dynamic>>> fetchBudgets() => _delegate.fetch();

  Future<void> deleteBudget(String remoteId) => _delegate.delete(remoteId);

  Stream<List<Map<String, dynamic>>> streamBudgets() => _delegate.stream();
}
