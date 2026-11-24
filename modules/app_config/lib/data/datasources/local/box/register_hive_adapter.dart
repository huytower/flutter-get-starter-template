
import 'package:app_config/data/adapters/domain_user_entity_adapter.dart';
import 'package:cc_sdk/export_cc_sdk.dart';
import 'package:hive_ce/hive_ce.dart';

import 'app_storage/prj_app_storage.dart';
import 'device_info/prj_device_info.dart';

/// Registers all Hive adapters used in the application.
///
/// This function should be called during app initialization, before any Hive operations are performed.
/// It registers all custom Hive adapters with their respective type IDs.
///
/// Throws [HiveError] if any adapter registration fails.
///
/// Example usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Hive.initFlutter();
///   await registerHiveAdapter();
///   runApp(MyApp());
/// }
/// ```
Future<void> registerHiveAdapter() async {
  try {
    Hive.registerAdapter(DomainUserEntityAdapter());

    await _registerAdapterWithErrorHandling(
      'PrjAppStorage',
      () => PrjAppStorage.register(),
    );

    await _registerAdapterWithErrorHandling(
      'PrjDeviceInfo',
      () => PrjDeviceInfo.register(),
    );
  } catch (e, stackTrace) {
    'Failed to register one or more Hive adapters: $e\n$stackTrace'.Log('Hive');
    rethrow;
  }
}

/// Helper function to register a single adapter with error handling and logging
Future<void> _registerAdapterWithErrorHandling(
  String adapterName,
  Future<void> Function() registerFunction,
) async {
  try {
    await registerFunction();
  } catch (e, stackTrace) {
    'Failed to register $adapterName adapter: $e\n$stackTrace'.Log('Hive');
    rethrow;
  }
}
