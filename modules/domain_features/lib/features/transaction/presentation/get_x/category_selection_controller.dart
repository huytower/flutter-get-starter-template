import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../category/data/datasources/local/category_seed.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../category/presentation/get_x/category_settings_controller.dart';

@injectable
class CategorySelectionController extends CcGetController {
  CategorySelectionController(this._getCategories);

  final GetCategoriesUseCase _getCategories;

  final RxList<CategoryEntity> categories = <CategoryEntity>[].obs;
  final RxnString selectedCategoryId = RxnString();
  final RxBool isLoading = true.obs;

  List<String>? groupIds;
  List<String>? categoryIds;
  String type = CategoryType.expense;
  bool autoSelectFirstEnabled = false;
  String? initialId;
  Function(CategoryEntity)? onSelected;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    ever(
      CategorySettingsController.onCategoryDefaultsApplied,
      (_) => loadCategories(),
    );
    ever(
      CategorySettingsController.onCategoriesChanged,
      (_) => loadCategories(),
    );

    // Ensure auto-selection/pre-selection happens even if categories load async
    ever(isLoading, (loading) {
      if (!loading) {
        _applyInitialSelection();
      }
    });
  }

  void _applyInitialSelection() {
    if (initialId != null) {
      final category = getCategoryById(initialId!);
      if (category != null) {
        final changed = selectedCategoryId.value != category.id;
        selectedCategoryId.value = category.id;
        initialId = null;
        // Only report to parent if it's a new selection to avoid rebuild loops
        if (changed) {
          _reportToParent(category);
        }
      }
    } else if (autoSelectFirstEnabled &&
        categories.isNotEmpty &&
        selectedCategoryId.value == null) {
      // Only auto-select if we don't have a selection yet
      final category = categories.first;
      selectedCategoryId.value = category.id;
      _reportToParent(category);
    }
  }

  void _reportToParent(CategoryEntity category) {
    // Check if parent is already in sync before reporting to prevent loops
    // In many forms, the parent passes us the selection via initialId,
    // so reporting it back can trigger a redundant parent rebuild.
    // However, we don't have a direct reference to parent's observable here.

    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSelected?.call(category);
      });
    } else {
      onSelected?.call(category);
    }
  }

  void refreshSelection({bool reload = false}) {
    if (reload) {
      loadCategories();
    } else if (!isLoading.value) {
      _applyInitialSelection();
    }
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    final result = await _getCategories();

    result.when(
      (allCategories) {
        // Create index map to preserve seed order
        final seedIndexMap = <String, int>{};
        for (int i = 0; i < CategorySeed.categories.length; i++) {
          seedIndexMap[CategorySeed.categories[i].id] = i;
        }

        final filteredCategories =
            allCategories
                .where(
                  (c) =>
                      c.isEnabled &&
                      c.type == type &&
                      (groupIds == null || groupIds!.contains(c.groupId)) &&
                      (categoryIds == null || categoryIds!.contains(c.id)),
                )
                .toList()
              ..sort((a, b) {
                final indexA = seedIndexMap[a.id] ?? 999;
                final indexB = seedIndexMap[b.id] ?? 999;
                return indexA.compareTo(indexB);
              });

        categories.assignAll(filteredCategories);
        isLoading.value = false;
      },
      (error) {
        isLoading.value = false;
      },
    );
  }

  void selectCategory(CategoryEntity category) {
    selectedCategoryId.value = category.id;
  }

  CategoryEntity? getCategoryById(String id) {
    return categories.firstWhereOrNull((c) => c.id == id);
  }

  CategoryEntity? getSelectedCategory() {
    if (selectedCategoryId.value == null) return null;
    return getCategoryById(selectedCategoryId.value!);
  }

  void autoSelectFirst() {
    if (categories.isNotEmpty && selectedCategoryId.value == null) {
      selectedCategoryId.value = categories.first.id;
    }
  }

  void preselectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
  }
}
