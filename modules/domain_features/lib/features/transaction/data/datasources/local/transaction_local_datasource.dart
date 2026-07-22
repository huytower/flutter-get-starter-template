import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/transaction_model.dart';

/// Local (Hive) persistence for transactions.
@lazySingleton
class TransactionLocalDataSource {
  Future<Box<TransactionModel>> get _box async {
    if (Hive.isBoxOpen(CcHiveBox.TRANSACTION_BOX_NAME)) {
      return Hive.box<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME);
    }
    return Hive.openBox<TransactionModel>(CcHiveBox.TRANSACTION_BOX_NAME);
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
    final targets = box.values
        .where((m) => m.walletId == walletId && m.deletedAt == null)
        .toList();
    for (final model in targets) {
      final id = model.id;
      if (id == null) continue;
      await box.put(id, model.copyWith(deletedAt: iso));
    }
  }

  Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }
}
