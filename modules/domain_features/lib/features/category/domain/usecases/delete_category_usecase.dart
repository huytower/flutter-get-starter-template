import 'package:cc_sdk_data/domain/failures/cc_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:multiple_result/multiple_result.dart';

import '../repositories/category_repository.dart';

@lazySingleton
class DeleteCategoryUseCase {
  DeleteCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  Future<Result<void, CcFailure>> call(String id) =>
      _repository.deleteCategory(id);
}
