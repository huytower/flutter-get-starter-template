import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/category_group_entity.dart';
import '../repositories/category_repository.dart';

@lazySingleton
class GetCategoryGroupsUseCase {
  GetCategoryGroupsUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Result<List<CategoryGroupEntity>, CcFailure>> call() =>
      _repository.getCategoryGroups();
}
