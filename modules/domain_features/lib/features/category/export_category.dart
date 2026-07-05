// Domain
export 'domain/entities/category_entity.dart';
export 'domain/entities/category_group_entity.dart';
export 'domain/repositories/category_repository.dart';
export 'domain/usecases/create_category_usecase.dart';
export 'domain/usecases/delete_category_usecase.dart';
export 'domain/usecases/get_categories_usecase.dart';
export 'domain/usecases/get_category_groups_usecase.dart';
// Data (model adapter exported so the app shell can register it with Hive)
export 'data/models/category_model.dart';
