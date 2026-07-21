library data;

export 'package:data_config/core/di/di.module.dart';

// Adapters
export 'data/adapters/domain_user_entity_adapter.dart';
// Converters
export 'data/converters/domain_user_entity_converter.dart';
// Core utilities
export 'core/util/firestore_sync_service.dart';

// Repositories (Contracts are in features, implementations are registered via DI)
// Only export if needed outside of automated DI.
