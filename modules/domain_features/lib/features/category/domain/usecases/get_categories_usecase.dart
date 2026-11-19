import 'package:cc_sdk_data/export_cc_sdk_data.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

@lazySingleton
class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Result<List<CategoryEntity>, CcFailure>> call() =>
      _repository.getCategories();
}
