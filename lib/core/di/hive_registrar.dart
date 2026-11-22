import 'package:app_config/data/datasources/local/box/register_hive_adapter.dart'
    as app_config;
import 'package:data_config/hive_registrar.g.dart' as data_config;
import 'package:domain_features/hive_registrar.g.dart' as domain_features;
import 'package:hive_ce/hive_ce.dart';

/// Central registrar for all Hive adapters across all modules.
class HiveRegistrar {
  /// Registers all adapters from all modules.
  static Future<void> registerAll() async {
    // 1. Core/App adapters (via app_config)
    await app_config.registerHiveAdapter();

    // 2. Feature and data adapters, from the registrars hive_ce generates in
    // each package, so a new @GenerateAdapters model needs no edit here. Both
    // extensions are named HiveRegistrar, hence the explicit application.
    domain_features.HiveRegistrar(Hive).registerAdapters();
    data_config.HiveRegistrar(Hive).registerAdapters();
  }
}
