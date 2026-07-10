import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/budget_model.dart';

/// Local (Hive) persistence for budgets.
@lazySingleton
class BudgetLocalDataSource {
  Future<Box<BudgetModel>> get _box async {
    return Hive.openBox<BudgetModel>(CcHiveBox.BUDGET_BOX_NAME);
  }

  Future<List<BudgetModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<BudgetModel?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> put(BudgetModel budget) async {
    final box = await _box;
    await box.put(budget.id, budget);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
