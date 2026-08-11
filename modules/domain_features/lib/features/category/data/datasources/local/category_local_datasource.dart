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
    if (Hive.isBoxOpen(CcHiveBox.CATEGORY_BOX_NAME)) {
      return Hive.box<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME);
    }
    final box = await Hive.openBox<CategoryModel>(CcHiveBox.CATEGORY_BOX_NAME);
    if (box.isEmpty) {
      await box.putAll({for (final c in CategorySeed.categories) c.id: c});
    } else {
      // Migration: insert seed categories missing from the box (e.g. income
      // seeds added in an update) and refresh a seeded category whenever its
      // fields change in [CategorySeed], so existing installs pick up fixes.
      // User-added categories (non-seed ids) are left untouched.
      final updates = <String, CategoryModel>{};
      for (final c in CategorySeed.categories) {
        final existing = box.get(c.id);
        if (existing == null ||
            existing.iconCode != c.iconCode ||
            existing.colorValue != c.colorValue ||
            existing.type != c.type ||
            existing.groupId != c.groupId ||
            existing.nameKey != c.nameKey) {
          updates[c.id] = c;
        }
      }
      if (updates.isNotEmpty) await box.putAll(updates);

      // Debt/Loan taxonomy rework: these ids were dropped from the seed
      // (duplicated other debt items) but never get cleaned up by the loop
      // above, since it only ever visits current seed ids. Delete them so
      // existing installs stop seeing them in the transaction category
      // picker, which filters by type/isEnabled only (not groupId).
      // 'd7' is included here rather than reused: pre-rework it was a single
      // generic "Debt Other" shared by both borrow and lend transactions, so
      // it can't be safely reassigned to either group's new id-matched seed
      // entry without silently reclassifying existing users' transactions.
      const staleIds = ['c15', 'c32', 'c33', 'd7'];
      for (final id in staleIds) {
        if (box.containsKey(id)) await box.delete(id);
      }
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

  Future<void> updateCategory(CategoryModel category) async {
    final box = await _box;
    await box.put(category.id, category);
  }

  Future<void> updateCategoryEnabled(String id, bool isEnabled) async {
    final box = await _box;
    final existing = box.get(id);
    if (existing == null) return;
    await box.put(
      id,
      CategoryModel(
        id: existing.id,
        nameKey: existing.nameKey,
        iconCode: existing.iconCode,
        iconFamily: existing.iconFamily,
        colorValue: existing.colorValue,
        groupId: existing.groupId,
        isEnabled: isEnabled,
        type: existing.type,
      ),
    );
  }
}
