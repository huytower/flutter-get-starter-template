import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
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

  final RxMap<String, bool> pending = <String, bool>{}.obs;
  final RxBool isSaving = false.obs;

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
    categoriesResult.when((categories) {
      final bg = <String, List<CategoryEntity>>{};
      final ibg = <String, List<CategoryEntity>>{};
      for (final cat in categories) {
        if (cat.type == CategoryType.income) {
          ibg.putIfAbsent(cat.groupId, () => []).add(cat);
        } else {
          bg.putIfAbsent(cat.groupId, () => []).add(cat);
        }
      }
      byGroup.assignAll(bg);
      incomeByGroup.assignAll(ibg);
    }, (_) {});

    layoutStatus.value = CcLayoutStatus.success;
  }

  bool isEnabled(CategoryEntity cat) =>
      pending.containsKey(cat.id) ? pending[cat.id]! : cat.isEnabled;

  bool get hasAnyEnabled => [
    ...byGroup.values.expand((c) => c),
    ...incomeByGroup.values.expand((c) => c),
  ].any(isEnabled);

  void toggle(CategoryEntity cat) {
    final current = isEnabled(cat);
    pending[cat.id] = !current;
    pending.refresh();
  }

  Future<void> save(BuildContext context) async {
    if (pending.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    isSaving.value = true;
    for (final entry in pending.entries) {
      final result = await _toggleEnabled(entry.key, entry.value);
      if (result.isError()) {
        isSaving.value = false;
        if (context.mounted) {
          CcSnackBarHelper.showErrorSnackBar(
            context: context,
            message: result.tryGetError()!.message,
          );
        }
        return;
      }
    }
    isSaving.value = false;
    if (context.mounted) {
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: el.tr(CcLocaleKeys.category_settings_saved),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (context.mounted) Navigator.of(context).pop(true);
    }
  }
}
