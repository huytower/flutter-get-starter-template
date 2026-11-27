import 'package:app_config/data/datasources/local/box/prj_hive_box.dart';
import 'package:cc_sdk/export_cc_sdk.dart' hide getIt;
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/transaction_model.dart';

/// Local (Hive) persistence for transactions.
@lazySingleton
class TransactionLocalDataSource {
  Future<Box<TransactionModel>> get _box async {
    if (Hive.isBoxOpen(PrjHiveBox.TRANSACTION_BOX_NAME)) {
      return Hive.box<TransactionModel>(PrjHiveBox.TRANSACTION_BOX_NAME);
    }
    return Hive.openBox<TransactionModel>(PrjHiveBox.TRANSACTION_BOX_NAME);
  }

  Future<List<TransactionModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<TransactionModel?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> add(TransactionModel transaction) async {
    final box = await _box;
    await box.put(transaction.id, transaction);
  }

  Future<void> update(TransactionModel transaction) async {
    final box = await _box;
    await box.put(transaction.id, transaction);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  /// Marks every non-deleted transaction of [walletId] as soft-deleted.
  Future<void> softDeleteByWallet(String walletId, DateTime deletedAt) async {
    final box = await _box;
    final iso = deletedAt.toIso8601String();
    // Also matches investmentWalletId so deleting an investment position
    // soft-deletes its Thu vào records too, even though those now live on a
    // liquid wallet's walletId rather than the position's.
    final targets = box.values
        .where(
          (m) =>
              (m.walletId == walletId || m.investmentWalletId == walletId) &&
              m.deletedAt == null,
        )
        .toList();
    for (final model in targets) {
      final id = model.id;
      if (id == null) continue;
      await box.put(id, model.copyWith(deletedAt: iso));
    }
    '[DeleteWallet] soft-deleted ${targets.length} transaction(s) of '
            'wallet=$walletId: ${targets.map((m) => '${m.id}(${m.type})').join(', ')}'
        .Log('DeleteWallet');
  }

  /// Marks the non-deleted transactions with the given [ids] as soft-deleted
  /// and flags them for the next sync.
  Future<void> softDeleteByIds(List<String> ids, DateTime deletedAt) async {
    final box = await _box;
    final iso = deletedAt.toIso8601String();
    for (final id in ids) {
      final model = box.get(id);
      if (model == null || model.deletedAt != null) continue;
      await box.put(
        id,
        model
            .copyWith(deletedAt: iso)
            .copyWithSyncMetadata(model.syncMetadata.withLocalChange(id)),
      );
    }
  }

  Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }
}
