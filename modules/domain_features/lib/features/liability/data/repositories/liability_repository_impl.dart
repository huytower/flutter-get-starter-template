import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/liability_entity.dart';
import '../../domain/repositories/liability_repository.dart';
import '../datasources/local/liability_local_datasource.dart';
import '../models/liability_model.dart';

@LazySingleton(as: LiabilityRepository)
class LiabilityRepositoryImpl with CcBaseRepository implements LiabilityRepository {
  @factoryMethod
  LiabilityRepositoryImpl({
    required LiabilityLocalDatasource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  final LiabilityLocalDatasource _local;
  final FinancialDataSyncService _syncService;

  @override
  Future<Result<List<LiabilityEntity>, CcFailure>> getLoans() {
    return safeRequest(() async {
      final models = await _local.getAll();
      return models.map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  @override
  Future<Result<LiabilityEntity, CcFailure>> getLoan(String id) {
    return safeRequest(() async {
      final model = await _local.getById(id);
      if (model == null) {
        throw StateError('Loan $id not found');
      }
      return model.toEntity();
    });
  }

  @override
  Future<Result<void, CcFailure>> createLoan(LiabilityEntity loan) {
    return safeRequest(() async {
      final model = LiabilityModel.fromEntity(loan);
      await _local.put(model);

      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id),
      );
      await _local.put(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> updateLoan(LiabilityEntity loan) {
    return safeRequest(() async {
      final existing = await _local.getById(loan.id);
      final model = LiabilityModel.fromEntity(loan);

      // Preserve remoteId and lastSyncedAt from existing model
      final toSave = existing != null
          ? model.copyWithSyncMetadata(
              existing.syncMetadata.withLocalChange(model.id),
            )
          : model.copyWithSyncMetadata(SyncMetadata.pending(model.id));

      await _local.put(toSave);
      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteLoan(String id) {
    return safeRequest(() async {
      await _local.delete(id);
      _syncService.syncAll();
    });
  }
}


