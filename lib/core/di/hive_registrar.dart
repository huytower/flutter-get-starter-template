import 'package:app_config/data/datasource/local/box/register_hive_adapter.dart'
    as app_config;
import 'package:domain_features/export_domain_features.dart';
import 'package:hive_ce/hive_ce.dart';

/// Central registrar for all Hive adapters across all modules.
class HiveRegistrar {
  /// Registers all adapters from all modules.
  static Future<void> registerAll() async {
    // 1. Register Core/App adapters (via app_config)
    await app_config.registerHiveAdapter();

    // 2. Register Feature adapters (that app_config cannot see)
    // We register them here because lib/ can see both modules.
    _registerFeatureAdapters();
  }

  static void _registerFeatureAdapters() {
    Hive.registerAdapter(WalletHiveModelAdapter());

    // Register Category adapter (data-layer model) from domain_features
    Hive.registerAdapter(CategoryModelAdapter());

    // Register Transaction adapter (data-layer model) from domain_features
    Hive.registerAdapter(TransactionModelAdapter());

    // Register Budget Limit adapter (data-layer model) from domain_features
    Hive.registerAdapter(BudgetLimitModelAdapter());

    // Register Reconciliation adapters (record + nested allocation)
    Hive.registerAdapter(ReconciliationAllocationModelAdapter());
    Hive.registerAdapter(ReconciliationModelAdapter());

    // Register Loan adapters (record + nested installment)
    Hive.registerAdapter(LiabilityInstallmentModelAdapter());
    Hive.registerAdapter(LiabilityModelAdapter());

    // Add other feature adapters here as needed
  }
}
