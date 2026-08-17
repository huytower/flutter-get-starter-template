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
      final cat = getCategoryById(initialId!);
      if (cat != null) {
        selectedCategoryId.value = cat.id;
        initialId = null;
      }
    } else if (autoSelectFirstEnabled && categories.isNotEmpty) {
      // If parent has no selection (initialId was null), we must enforce
      // the auto-selection or re-report our current selection to sync.
      if (selectedCategoryId.value == null) {
        final cat = categories.first;
        selectedCategoryId.value = cat.id;
        _reportToParent(cat);
      } else {
        // Controller was reused and has a selection, but parent has null.
        // Sync parent to our current selection.
        final current = getSelectedCategory();
        if (current != null) {
          _reportToParent(current);
        }
      }
    }
  }

  void _reportToParent(CategoryEntity cat) {
    // Use post-frame callback if currently in a build phase to avoid
    // "setState() or markNeedsBuild() called during build" errors.
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSelected?.call(cat);
      });
    } else {
      onSelected?.call(cat);
    }
  }

  void refreshSelection() {
    if (!isLoading.value) {
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
                      (groupIds == null || groupIds!.contains(c.groupId)),
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
