import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/loan_model.dart';

/// Local (Hive) persistence for loan records.
@lazySingleton
class LoanLocalDataSource {
  Future<Box<LoanModel>> get _box async {
    if (Hive.isBoxOpen(CcHiveBox.LOAN_BOX_NAME)) {
      return Hive.box<LoanModel>(CcHiveBox.LOAN_BOX_NAME);
    }
    return Hive.openBox<LoanModel>(CcHiveBox.LOAN_BOX_NAME);
  }

  Future<List<LoanModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<LoanModel?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> put(LoanModel loan) async {
    final box = await _box;
    await box.put(loan.id, loan);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
