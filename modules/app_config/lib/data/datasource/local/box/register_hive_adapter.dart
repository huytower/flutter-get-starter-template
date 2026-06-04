import 'dart:developer' as developer;

import 'app_storage/cc_app_storage.dart';
import 'device_info/cc_device_info.dart';

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
    await _registerAdapterWithErrorHandling(
      'CcAppStorage',
      () => CcAppStorage.register(),
    );

    await _registerAdapterWithErrorHandling(
      'CcDeviceInfo',
      () => CcDeviceInfo.register(),
    );
  } catch (e, stackTrace) {
    developer.log(
      'Failed to register one or more Hive adapters',
      error: e,
      stackTrace: stackTrace,
    );
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
    developer.log(
      'Failed to register $adapterName adapter',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}
