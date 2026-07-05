import 'package:app_config/data/datasource/local/box/cc_hive_box.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';

import '../../models/category_model.dart';
import 'category_seed.dart';

/// Local (Hive) persistence for categories.
///
/// Seeds [CategorySeed.categories] on first launch (empty box).
@lazySingleton
class CategoryLocalDataSource {
  Future<Box<CategoryModel>> get _box async {
    final box = await Hive.openBox<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME);
    if (box.isEmpty) {
      await box.putAll({for (final c in CategorySeed.categories) c.id: c});
    } else {
      // Migration: refresh a seeded category whenever its icon changes in
      // [CategorySeed], so existing installs pick up icon fixes. User-added
      // categories (non-seed ids) are left untouched.
      final updates = <String, CategoryModel>{
        for (final c in CategorySeed.categories)
          if (box.get(c.id)?.iconCode != c.iconCode) c.id: c,
      };
      if (updates.isNotEmpty) await box.putAll(updates);
    }
    return box;
  }

  Future<List<CategoryModel>> getCategories() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<CategoryModel?> getCategory(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> addCategory(CategoryModel category) async {
    final box = await _box;
    await box.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
