import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/budget_limit_model.dart';

/// Local (Hive) persistence for budgets.
@lazySingleton
class BudgetLimitLocalDataSource {
  Future<Box<BudgetLimitModel>> get _box async {
    return Hive.openBox<BudgetLimitModel>(CcHiveBox.BUDGET_BOX_NAME);
  }

  Future<List<BudgetLimitModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<BudgetLimitModel?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> put(BudgetLimitModel budget) async {
    final box = await _box;
    await box.put(budget.id, budget);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
