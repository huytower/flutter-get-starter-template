import 'package:cc_bridge/export_cc_bridge.dart' hide getIt;
import 'package:data_config/core/util/firestore_sync_service.dart';
import 'package:data_config/core/util/generic_sync_datasource.dart';
import 'package:injectable/injectable.dart';

import '../models/loan_model.dart';

@injectable
class LoanSyncDataSource {
  final GenericSyncDataSource _delegate;

  LoanSyncDataSource(FirestoreSyncService syncService, SessionContract session)
    : _delegate = GenericSyncDataSource(syncService, session, 'loans');

  Future<String?> syncLoan(LoanModel loan) => _delegate.sync(
    localId: loan.id,
    data: loan.toFirestoreData(),
    remoteId: loan.syncMetadata.remoteId,
    lastSyncedAt: loan.syncMetadata.lastSyncedAt,
  );

  Future<List<Map<String, dynamic>>> fetchLoans() => _delegate.fetch();

  Future<void> deleteLoan(String remoteId) => _delegate.delete(remoteId);

  Stream<List<Map<String, dynamic>>> streamLoans() => _delegate.stream();
}
