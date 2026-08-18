import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/liability_model.dart';

/// Local (Hive) persistence for loan records.
@lazySingleton
class LiabilityLocalDatasource {
  Future<Box<LiabilityModel>> get _box async {
    if (Hive.isBoxOpen(CcHiveBox.LOAN_BOX_NAME)) {
      return Hive.box<LiabilityModel>(CcHiveBox.LOAN_BOX_NAME);
    }
    return Hive.openBox<LiabilityModel>(CcHiveBox.LOAN_BOX_NAME);
  }

  Future<List<LiabilityModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<LiabilityModel?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> put(LiabilityModel loan) async {
    final box = await _box;
    await box.put(loan.id, loan);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}


