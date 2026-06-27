import 'package:app_config/data/datasource/local/box/register_hive_adapter.dart' as app_config;
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
    // Register Wallet adapter from domain_features
    // Note: WalletEntityAdapter is generated in domain_features
    Hive.registerAdapter(WalletEntityAdapter());

    // Add other feature adapters here as needed
  }
}
