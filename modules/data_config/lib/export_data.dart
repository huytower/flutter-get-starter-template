library data;

export 'package:data_config/core/di/di.module.dart';

// Exchange Rates Hive Model
export 'data/exchange_rates/exchange_rate_hive_model.dart';

// Repositories (Contracts are in features, implementations are registered via DI)
// Only export if needed outside of automated DI.
