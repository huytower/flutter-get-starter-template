/// Simplified Hive Configuration
///
/// This file contains all Hive-related constants in one place.
///
/// How to use:
/// 1. For @HiveType, use the _TYPE_ID constants
/// 2. For box names, use the _BOX_NAME constants
///
/// Example:
/// ```dart
/// @HiveType(typeId: CcHiveBox.APP_STORAGE_TYPE_ID)
/// class AppStorage extends HiveObject {
///   @HiveField(0) final String id;
///   // ...
/// }
///
/// // To open a box:
/// final box = await Hive.openBox(CcHiveBox.APP_BOX_NAME);
/// ```
class CcHiveBox {
  // Prevent instantiation
  CcHiveBox._();

  // ===== Type IDs =====
  // Use these with @HiveType(typeId: )
  static const int APP_STORAGE_TYPE_ID = 2;
  static const int DEVICE_TYPE_ID = 3;
  static const int APP_TRACK_LOG_TYPE_ID = 4;
  static const int WALLET_TYPE_ID = 5;

  // Add new type IDs here (next would be 6)

  // ===== Box Names =====
  // Use these with Hive.openBox()
  static const String APP_BOX_NAME = 'application';
  static const String DEVICE_BOX_NAME = 'device';
  static const String TRACK_LOG_BOX_NAME = 'track_log';
  static const String WALLET_BOX_NAME = 'wallet';

  static const keyDefault = 'key_default';
}
