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

  // Non-financial data (unencrypted)
  static const int APP_STORAGE_TYPE_ID = 2;
  static const int DEVICE_TYPE_ID = 3;
  static const int APP_TRACK_LOG_TYPE_ID = 4;

  // Financial data (encrypted)
  static const int WALLET_TYPE_ID = 5;
  static const int CATEGORY_TYPE_ID = 6;
  static const int TRANSACTION_TYPE_ID = 7;
  static const int BUDGET_TYPE_ID = 8;
  static const int RECONCILIATION_TYPE_ID = 9;
  static const int RECONCILIATION_ALLOCATION_TYPE_ID = 10;
  static const int LOAN_TYPE_ID = 11;
  static const int LOAN_INSTALLMENT_TYPE_ID = 12;

  // Add new type IDs here (next would be 13)

  // ===== Box Names =====
  // Use these with Hive.openBox()

  // Non-financial boxes (unencrypted)
  static const String APP_BOX_NAME = 'application';
  static const String DEVICE_BOX_NAME = 'device';
  static const String TRACK_LOG_BOX_NAME = 'track_log';

  // Financial boxes (encrypted)
  static const String WALLET_BOX_NAME = 'wallet';
  static const String CATEGORY_BOX_NAME = 'category';
  static const String TRANSACTION_BOX_NAME = 'transaction';
  static const String BUDGET_BOX_NAME = 'budget';
  static const String RECONCILIATION_BOX_NAME = 'reconciliation';
  static const String LOAN_BOX_NAME = 'loan';

  static const keyDefault = 'key_default';

  // ===== Box Classification =====

  /// Returns true if the box contains sensitive financial data that should be encrypted.
  static bool isFinancialBox(String boxName) {
    return [
      WALLET_BOX_NAME,
      CATEGORY_BOX_NAME,
      TRANSACTION_BOX_NAME,
      BUDGET_BOX_NAME,
      RECONCILIATION_BOX_NAME,
      LOAN_BOX_NAME,
    ].contains(boxName);
  }

  /// Returns true if the box contains non-financial data that can remain unencrypted.
  static bool isNonFinancialBox(String boxName) {
    return [
      APP_BOX_NAME,
      DEVICE_BOX_NAME,
      TRACK_LOG_BOX_NAME,
    ].contains(boxName);
  }

  /// List of all financial box names.
  static const List<String> financialBoxes = [
    WALLET_BOX_NAME,
    CATEGORY_BOX_NAME,
    TRANSACTION_BOX_NAME,
    BUDGET_BOX_NAME,
    RECONCILIATION_BOX_NAME,
    LOAN_BOX_NAME,
  ];

  /// List of all non-financial box names.
  static const List<String> nonFinancialBoxes = [
    APP_BOX_NAME,
    DEVICE_BOX_NAME,
    TRACK_LOG_BOX_NAME,
  ];
}
