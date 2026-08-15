import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/transaction_template_entity.dart';
import '../../domain/repositories/transaction_template_repository.dart';
import '../datasources/local/transaction_template_local_datasource.dart';
import '../models/transaction_template_model.dart';

@LazySingleton(as: TransactionTemplateRepository)
class TransactionTemplateRepositoryImpl
    with CcBaseRepository
    implements TransactionTemplateRepository {
  @factoryMethod
  TransactionTemplateRepositoryImpl({
    required TransactionTemplateLocalDataSource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  final TransactionTemplateLocalDataSource _local;
  final FinancialDataSyncService _syncService;

  @override
  Future<Result<List<TransactionTemplateEntity>, CcFailure>>
  getTemplates() {
    return safeRequest(() async {
      final models = await _local.getAll();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<void, CcFailure>> createTemplate(
    TransactionTemplateEntity template,
  ) {
    return safeRequest(() async {
      final model = TransactionTemplateModel.fromEntity(template);
      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id),
      );
      await _local.put(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteTemplate(String id) {
    return safeRequest(() async {
      await _local.delete(id);
      _syncService.syncAll();
    });
  }
}
