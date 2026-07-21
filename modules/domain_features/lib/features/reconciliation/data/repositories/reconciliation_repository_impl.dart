import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/reconciliation_entity.dart';
import '../../domain/repositories/reconciliation_repository.dart';
import '../datasources/local/reconciliation_local_datasource.dart';
import '../models/reconciliation_model.dart';

@LazySingleton(as: ReconciliationRepository)
class ReconciliationRepositoryImpl
    with CcBaseRepository
    implements ReconciliationRepository {
  @factoryMethod
  ReconciliationRepositoryImpl({
    required ReconciliationLocalDataSource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  final ReconciliationLocalDataSource _local;
  final FinancialDataSyncService _syncService;

  Future<List<ReconciliationEntity>> _allSortedDesc() async {
    final models = await _local.getAll();
    final entities = models.map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return entities;
  }

  @override
  Future<Result<List<ReconciliationEntity>, CcFailure>> getReconciliations() {
    return safeRequest(() => _allSortedDesc());
  }

  @override
  Future<Result<ReconciliationEntity?, CcFailure>> getLatest() {
    return safeRequest(() async {
      final all = await _allSortedDesc();
      return all.isEmpty ? null : all.first;
    });
  }

  @override
  Future<Result<void, CcFailure>> saveReconciliation(
    ReconciliationEntity reconciliation,
  ) {
    return safeRequest(() async {
      final model = ReconciliationModel.fromEntity(reconciliation);
      await _local.put(model);

      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id),
      );
      await _local.put(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteReconciliation(String id) {
    return safeRequest(() async {
      await _local.delete(id);
      _syncService.syncAll();
    });
  }
}
