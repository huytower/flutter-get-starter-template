import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/reconciliation_model.dart';

/// Local (Hive) persistence for reconciliation records.
@lazySingleton
class ReconciliationLocalDataSource {
  Future<Box<ReconciliationModel>> get _box async {
    if (Hive.isBoxOpen(CcHiveBox.RECONCILIATION_BOX_NAME)) {
      return Hive.box<ReconciliationModel>(CcHiveBox.RECONCILIATION_BOX_NAME);
    }
    return Hive.openBox<ReconciliationModel>(CcHiveBox.RECONCILIATION_BOX_NAME);
  }

  Future<List<ReconciliationModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> put(ReconciliationModel reconciliation) async {
    final box = await _box;
    await box.put(reconciliation.id, reconciliation);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
