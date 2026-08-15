import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/transaction_template_model.dart';

/// Local (Hive) persistence for quick-entry templates.
@lazySingleton
class TransactionTemplateLocalDataSource {
  Future<Box<TransactionTemplateModel>> get _box async {
    if (Hive.isBoxOpen(CcHiveBox.TRANSACTION_TEMPLATE_BOX_NAME)) {
      return Hive.box<TransactionTemplateModel>(
        CcHiveBox.TRANSACTION_TEMPLATE_BOX_NAME,
      );
    }
    return Hive.openBox<TransactionTemplateModel>(
      CcHiveBox.TRANSACTION_TEMPLATE_BOX_NAME,
    );
  }

  Future<List<TransactionTemplateModel>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> put(TransactionTemplateModel template) async {
    final box = await _box;
    await box.put(template.id, template);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
