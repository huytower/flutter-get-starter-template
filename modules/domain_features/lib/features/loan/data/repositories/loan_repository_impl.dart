import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/loan_entity.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/local/loan_local_datasource.dart';
import '../models/loan_model.dart';

@LazySingleton(as: LoanRepository)
class LoanRepositoryImpl with CcBaseRepository implements LoanRepository {
  @factoryMethod
  LoanRepositoryImpl({
    required LoanLocalDataSource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  final LoanLocalDataSource _local;
  final FinancialDataSyncService _syncService;

  @override
  Future<Result<List<LoanEntity>, CcFailure>> getLoans() {
    return safeRequest(() async {
      final models = await _local.getAll();
      return models.map((m) => m.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  @override
  Future<Result<LoanEntity, CcFailure>> getLoan(String id) {
    return safeRequest(() async {
      final model = await _local.getById(id);
      if (model == null) {
        throw StateError('Loan $id not found');
      }
      return model.toEntity();
    });
  }

  @override
  Future<Result<void, CcFailure>> createLoan(LoanEntity loan) {
    return safeRequest(() async {
      final model = LoanModel.fromEntity(loan);
      await _local.put(model);

      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id),
      );
      await _local.put(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> updateLoan(LoanEntity loan) {
    return safeRequest(() async {
      final existing = await _local.getById(loan.id);
      final model = LoanModel.fromEntity(loan);

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
