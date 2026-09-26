import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/budget_limit_entity.dart';
import '../../domain/repositories/budget_limit_repository.dart';
import '../datasources/local/budget_limit_local_datasource.dart';
import '../models/budget_limit_model.dart';

@LazySingleton(as: BudgetLimitRepository)
class BudgetLimitRepositoryImpl
    with CcBaseRepository
    implements BudgetLimitRepository {
  @factoryMethod
  BudgetLimitRepositoryImpl({
    required BudgetLimitLocalDataSource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  final BudgetLimitLocalDataSource _local;
  final FinancialDataSyncService _syncService;

  @override
  Future<Result<List<BudgetLimitEntity>, CcFailure>> getBudgets({
    bool activeOnly = true,
  }) {
    return safeRequest(() async {
      final models = await _local.getAll();
      final uniqueMap = <String, BudgetLimitEntity>{};
      for (final m in models) {
        final entity = m.toEntity();
        if (activeOnly && entity.isClosed) continue;
        final key = entity.categoryId.isNotEmpty
            ? entity.categoryId
            : entity.name.trim().toLowerCase();
        if (!uniqueMap.containsKey(key)) {
          uniqueMap[key] = entity;
        }
      }
      final budgets = uniqueMap.values.toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return budgets;
    });
  }

  @override
  Future<Result<BudgetLimitEntity, CcFailure>> getBudget(String id) {
    return safeRequest(() async {
      final model = await _local.getById(id);
      if (model == null) {
        throw StateError('Budget not found: $id');
      }
      return model.toEntity();
    });
  }

  @override
  Future<Result<void, CcFailure>> createBudget(BudgetLimitEntity budget) {
    return safeRequest(() async {
      final model = BudgetLimitModel.fromEntity(budget);
      await _local.put(model);

      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id),
      );
      await _local.put(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> updateBudget(BudgetLimitEntity budget) {
    return safeRequest(() async {
      final model = BudgetLimitModel.fromEntity(budget);
      await _local.put(model);

      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id),
      );
      await _local.put(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteBudget(String id) {
    return safeRequest(() async {
      final target = await _local.getById(id);
      if (target != null) {
        final all = await _local.getAll();
        for (final m in all) {
          final sameCategory = target.categoryId.isNotEmpty &&
              m.categoryId == target.categoryId;
          final sameName = m.name.trim().toLowerCase() ==
              target.name.trim().toLowerCase();
          if (m.id == id || sameCategory || sameName) {
            await _local.delete(m.id);
          }
        }
      } else {
        await _local.delete(id);
      }
      _syncService.syncAll();
    });
  }
}
