import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local/budget_local_datasource.dart';
import '../models/budget_model.dart';

@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl with CcBaseRepository implements BudgetRepository {
  @factoryMethod
  BudgetRepositoryImpl({required BudgetLocalDataSource local}) : _local = local;

  final BudgetLocalDataSource _local;

  @override
  Future<Result<List<BudgetEntity>, CcFailure>> getBudgets({
    bool activeOnly = true,
  }) {
    return safeRequest(() async {
      final models = await _local.getAll();
      final budgets = models
          .map((m) => m.toEntity())
          .where((b) => !activeOnly || !b.isClosed)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return budgets;
    });
  }

  @override
  Future<Result<BudgetEntity, CcFailure>> getBudget(String id) {
    return safeRequest(() async {
      final model = await _local.getById(id);
      if (model == null) {
        throw StateError('Budget not found: $id');
      }
      return model.toEntity();
    });
  }

  @override
  Future<Result<void, CcFailure>> createBudget(BudgetEntity budget) {
    return safeRequest(() async {
      await _local.put(BudgetModel.fromEntity(budget));
    });
  }

  @override
  Future<Result<void, CcFailure>> updateBudget(BudgetEntity budget) {
    return safeRequest(() async {
      await _local.put(BudgetModel.fromEntity(budget));
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteBudget(String id) {
    return safeRequest(() async {
      await _local.delete(id);
    });
  }
}
