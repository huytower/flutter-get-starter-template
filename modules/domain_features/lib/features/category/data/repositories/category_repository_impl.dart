import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:data_config/core/repository/cc_base_repository.dart';
import 'package:domain_features/features/firestore/financial_data_sync_service.dart';
import 'package:domain_features/features/firestore/model/sync_metadata.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/category_group_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/category_local_datasource.dart';
import '../datasources/local/category_seed.dart' as seed;
import '../models/category_model.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl
    with CcBaseRepository
    implements CategoryRepository {
  @factoryMethod
  CategoryRepositoryImpl({
    required CategoryLocalDataSource local,
    required FinancialDataSyncService syncService,
  }) : _local = local,
       _syncService = syncService;

  final CategoryLocalDataSource _local;
  final FinancialDataSyncService _syncService;

  @override
  Future<Result<List<CategoryEntity>, CcFailure>> getCategories() {
    return safeRequest(() async {
      final models = await _local.getCategories();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<CategoryEntity, CcFailure>> getCategory(String id) {
    return safeRequest(() async {
      final model = await _local.getCategory(id);
      if (model == null) {
        throw StateError('Category not found: $id');
      }
      return model.toEntity();
    });
  }

  @override
  Future<Result<List<CategoryGroupEntity>, CcFailure>> getCategoryGroups() {
    return safeRequest(() async => seed.CategorySeed.groups);
  }

  @override
  Future<Result<void, CcFailure>> addCategory(CategoryEntity category) {
    return safeRequest(() async {
      final model = CategoryModel.fromEntity(category);
      await _local.addCategory(model);

      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id),
      );
      await _local.updateCategory(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> updateCategory(CategoryEntity category) {
    return safeRequest(() async {
      final model = CategoryModel.fromEntity(category);
      await _local.updateCategory(model);

      final pending = model.copyWithSyncMetadata(
        SyncMetadata.pending(model.id),
      );
      await _local.updateCategory(pending);

      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> deleteCategory(String id) {
    return safeRequest(() async {
      await _local.deleteCategory(id);
      _syncService.syncAll();
    });
  }

  @override
  Future<Result<void, CcFailure>> updateCategoryEnabled(
    String id,
    bool isEnabled,
  ) {
    return safeRequest(() async {
      await _local.updateCategoryEnabled(id, isEnabled);
      _syncService.syncAll();
    });
  }
}
