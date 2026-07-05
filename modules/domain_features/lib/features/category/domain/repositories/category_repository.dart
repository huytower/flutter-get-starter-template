import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/category_entity.dart';
import '../entities/category_group_entity.dart';

abstract class CategoryRepository {
  Future<Result<List<CategoryEntity>, CcFailure>> getCategories();

  Future<Result<CategoryEntity, CcFailure>> getCategory(String id);

  Future<Result<List<CategoryGroupEntity>, CcFailure>> getCategoryGroups();

  Future<Result<void, CcFailure>> addCategory(CategoryEntity category);

  Future<Result<void, CcFailure>> deleteCategory(String id);
}
