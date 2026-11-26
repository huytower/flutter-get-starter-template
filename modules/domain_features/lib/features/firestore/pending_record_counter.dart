import 'package:app_config/data/datasources/local/box/prj_hive_box.dart';
import 'package:domain_features/features/firestore/enum/sync_status.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../features/budget_limit/data/models/budget_limit_model.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/liability/data/models/liability_model.dart';
import '../../features/reconciliation/data/models/reconciliation_model.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/wallet/data/models/wallet_hive_model.dart';
import 'pending_cloud_deletes.dart';

/// Counts the financial records stored on the device that are not backed up
/// to the cloud yet (pending or failed), across every synced Hive box.
class PendingRecordCounter {
  const PendingRecordCounter._();

  /// Records not yet uploaded plus deletes not yet applied in the cloud.
  static int count() =>
      PendingCloudDeletes.count +
      _inBox<WalletHiveModel>(
        PrjHiveBox.WALLET_BOX_NAME,
        (m) => m.syncMetadata.status,
      ) +
      _inBox<TransactionModel>(
        PrjHiveBox.TRANSACTION_BOX_NAME,
        (m) => m.syncMetadata.status,
      ) +
      _inBox<BudgetLimitModel>(
        PrjHiveBox.BUDGET_BOX_NAME,
        (m) => m.syncMetadata.status,
      ) +
      _inBox<ReconciliationModel>(
        PrjHiveBox.RECONCILIATION_BOX_NAME,
        (m) => m.syncMetadata.status,
      ) +
      _inBox<CategoryModel>(
        PrjHiveBox.CATEGORY_BOX_NAME,
        (m) => m.syncMetadata.status,
      ) +
      _inBox<LiabilityModel>(
        PrjHiveBox.LIABILITY_BOX_NAME,
        (m) => m.syncMetadata.status,
      );

  static int _inBox<T>(String boxName, SyncStatus Function(T) statusOf) {
    try {
      if (!Hive.isBoxOpen(boxName)) return 0;
      return Hive.box<T>(boxName).values.where((m) {
        final status = statusOf(m);
        return status == SyncStatus.pending || status == SyncStatus.failed;
      }).length;
    } catch (_) {
      return 0;
    }
  }
}
