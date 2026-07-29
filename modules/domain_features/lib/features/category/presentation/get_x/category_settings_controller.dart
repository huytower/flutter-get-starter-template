import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/category_group_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_category_groups_usecase.dart';
import '../../domain/usecases/toggle_category_enabled_usecase.dart';

@injectable
class CategorySettingsController extends CcGetController {
  CategorySettingsController(
    this._getGroups,
    this._getCategories,
    this._toggleEnabled,
  );

  final GetCategoryGroupsUseCase _getGroups;
  final GetCategoriesUseCase _getCategories;
  final ToggleCategoryEnabledUseCase _toggleEnabled;

  final RxList<CategoryGroupEntity> groups = <CategoryGroupEntity>[].obs;
  final RxMap<String, List<CategoryEntity>> byGroup =
      <String, List<CategoryEntity>>{}.obs;
  final RxMap<String, List<CategoryEntity>> incomeByGroup =
      <String, List<CategoryEntity>>{}.obs;
  final RxMap<String, List<CategoryEntity>> debtLoanByGroup =
      <String, List<CategoryEntity>>{}.obs;
  final RxMap<String, List<CategoryEntity>> investmentByGroup =
      <String, List<CategoryEntity>>{}.obs;

  final RxMap<String, bool> pending = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    layoutStatus.value = CcLayoutStatus.loading;
    final groupsResult = await _getGroups();
    final categoriesResult = await _getCategories();

    groupsResult.when((g) => groups.assignAll(g), (_) {});
    categoriesResult.when((categories) async {
      // FIX: Force migration for legacy Debt categories.
      // If we see IDs starting with 'd' but they aren't 'debtLoan' type, they are stale.
      final needsMigration = categories.any(
        (c) => c.id.startsWith('d') && c.type != CategoryType.debtLoan,
      );

      if (needsMigration) {
        'Fixing stale database records...'.Log('CategorySettingsController');
        for (final cat in categories) {
          if (cat.id.startsWith('d') || cat.id.startsWith('inv')) {
            // This triggers an update in CategoryLocalDataSource using the latest seed data
            await _toggleEnabled(cat.id, cat.isEnabled);
          }
        }
        await load(); // Recursive reload to pick up fixed data
        return;
      }

      final bg = <String, List<CategoryEntity>>{};
      final ibg = <String, List<CategoryEntity>>{};
      final dlbg = <String, List<CategoryEntity>>{};
      final invbg = <String, List<CategoryEntity>>{};
      for (final cat in categories) {
        if (cat.type == CategoryType.income) {
          ibg.putIfAbsent(cat.groupId, () => []).add(cat);
        } else if (cat.type == CategoryType.debtLoan) {
          dlbg.putIfAbsent(cat.groupId, () => []).add(cat);
        } else if (cat.type == CategoryType.investment) {
          invbg.putIfAbsent(cat.groupId, () => []).add(cat);
        } else {
          bg.putIfAbsent(cat.groupId, () => []).add(cat);
        }
      }

      'Loaded categories: ${categories.length}'.Log(
        'CategorySettingsController',
      );
      'Debt/Loan groups: ${dlbg.keys.join(', ')}'.Log(
        'CategorySettingsController',
      );
      for (final entry in dlbg.entries) {
        'Group ${entry.key}: ${entry.value.length} items'.Log(
          'CategorySettingsController',
        );
      }

      byGroup.assignAll(bg);
      incomeByGroup.assignAll(ibg);
      debtLoanByGroup.assignAll(dlbg);
      investmentByGroup.assignAll(invbg);
    }, (_) {});

    layoutStatus.value = CcLayoutStatus.success;
  }

  bool isEnabled(CategoryEntity cat) =>
      pending.containsKey(cat.id) ? pending[cat.id]! : cat.isEnabled;

  void toggle(CategoryEntity cat) async {
    final current = isEnabled(cat);
    final next = !current;

    // Optimistic UI update
    pending[cat.id] = next;
    pending.refresh();

    final result = await _toggleEnabled(cat.id, next);
    if (result.isError()) {
      // Revert UI on error
      pending[cat.id] = current;
      pending.refresh();
    }
  }
}
