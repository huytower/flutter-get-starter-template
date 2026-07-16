// Domain
export 'data/datasources/local/category_seed.dart';
// Data (model adapter exported so the app shell can register it with Hive)
export 'data/models/category_model.dart';
export 'domain/entities/category_entity.dart';
export 'domain/entities/category_group_entity.dart';
export 'domain/repositories/category_repository.dart';
export 'domain/usecases/create_category_usecase.dart';
export 'domain/usecases/delete_category_usecase.dart';
export 'domain/usecases/get_categories_usecase.dart';
export 'domain/usecases/get_category_groups_usecase.dart';
export 'domain/usecases/toggle_category_enabled_usecase.dart';
export 'domain/usecases/update_category_usecase.dart';
// Presentation
export 'presentation/pages/category_settings_page.dart';
export 'presentation/pages/income_category_settings_page.dart';
