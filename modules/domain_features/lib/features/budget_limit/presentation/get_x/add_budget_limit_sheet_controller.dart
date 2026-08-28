import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/getx/cc_get_controller.dart';
import '../../../guideline/guideline_controller.dart';
import '../../domain/entities/budget_limit_entity.dart';
import '../../domain/usecases/create_budget_limit_usecase.dart';
import '../../domain/usecases/get_category_average_monthly_spend_usecase.dart';
import '../../domain/usecases/update_budget_limit_usecase.dart';
import '../get_x/budget_limit_controller.dart';

@injectable
class AddBudgetLimitSheetController extends CcGetController {
  AddBudgetLimitSheetController(
    this._getCategories,
    this._getAverageSpend,
    this._budgetLimitController,
  );

  final GetCategoriesUseCase _getCategories;
  final GetCategoryAverageMonthlySpendUseCase _getAverageSpend;
  final BudgetLimitController _budgetLimitController;

  late final TextEditingController nameController;
  final RxString limitStr = '0'.obs;
  final RxnString nameError = RxnString();
  final RxBool showKeypad = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxList<CategoryEntity> categories = <CategoryEntity>[].obs;
  final RxnString selectedCategoryId = RxnString();
  final GlobalKey amountFieldKey = GlobalKey();
  ScrollController categoryScrollController = ScrollController();

  final RxBool isFixedPrice = false.obs;
  final RxnInt estimatedLimit = RxnInt();

  BudgetLimitEntity? _editTarget;

  bool get isEdit => _editTarget != null;

  bool get limitLocked => isEdit && !UpdateBudgetLimitUseCase.isLimitEditable;

  bool get isValid {
    final name = nameController.text.trim();
    if (name.isEmpty || selectedCategoryId.value == null) return false;
    if (limitLocked) return true;
    final limit = int.tryParse(limitStr.value.trim()) ?? 0;
    return limit > 0;
  }

  void init(BudgetLimitEntity? editTarget) {
    _editTarget = editTarget;
    nameController = TextEditingController(text: editTarget?.name ?? '');
    nameController.addListener(_onNameChanged);

    if (editTarget != null) {
      selectedCategoryId.value = editTarget.categoryId;
      limitStr.value = editTarget.limit.toString();
      isFixedPrice.value = editTarget.isFixedPrice;
    }

    if (!isEdit) _loadCategories();
  }

  void _onNameChanged() {
    if (nameError.value != null) {
      nameError.value = null;
    }
  }

  Future<void> _loadCategories() async {
    final result = await _getCategories.call();
    if (isClosed) return;
    result.when((cats) {
      final seedIndexMap = <String, int>{};
      for (int i = 0; i < CategorySeed.categories.length; i++) {
        seedIndexMap[CategorySeed.categories[i].id] = i;
      }

      final enabled = cats
          .where((c) => c.isEnabled && c.type == CategoryType.expense)
          .toList()
        ..sort((a, b) {
          final indexA = seedIndexMap[a.id] ?? 999;
          final indexB = seedIndexMap[b.id] ?? 999;
          return indexA.compareTo(indexB);
        });

      categories.assignAll(enabled);
      if (selectedCategoryId.value == null && enabled.isNotEmpty) {
        selectedCategoryId.value = enabled.first.id;
        nameController.text = el.tr(enabled.first.nameKey);
      }
      _scrollToSelectedCategory();
      if (selectedCategoryId.value != null) {
        _loadEstimate(selectedCategoryId.value!);
      }
    }, (_) {});
  }

  Future<void> _loadEstimate(String categoryId) async {
    final result = await _getAverageSpend.call(categoryId);
    if (isClosed) return;
    final estimate = result.tryGetSuccess() ?? 0;
    estimatedLimit.value = estimate > 0 ? estimate : null;
  }

  void applyEstimate() {
    limitStr.value = estimatedLimit.value.toString();
    estimatedLimit.value = null;
  }

  void _scrollToSelectedCategory() {
    if (selectedCategoryId.value == null) return;
    final index = categories.indexWhere((c) => c.id == selectedCategoryId.value);
    if (index <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      categoryScrollController.animateTo(
        index * 76.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  void onKeyPress(String key) {
    if (limitStr.value == '0') {
      if (key != '0' && key != '000') limitStr.value = key;
    } else {
      limitStr.value += key;
    }
  }

  void onDeleteKey() {
    if (limitStr.value.length > 1) {
      limitStr.value = limitStr.value.substring(0, limitStr.value.length - 1);
    } else {
      limitStr.value = '0';
    }
  }

  Future<void> save(BuildContext context) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    final budgetName = nameController.text.trim();
    final isDuplicate = _budgetLimitController.budgets.any((b) {
      if (isEdit && b.budget.id == _editTarget!.id) return false;
      return b.budget.name.trim().toLowerCase() == budgetName.toLowerCase();
    });

    if (isDuplicate) {
      nameError.value = el.tr(CcLocaleKeys.budget_name_duplicate_error);
      isSubmitting.value = false;
      return;
    }

    final limit = int.tryParse(limitStr.value.trim()) ?? 0;

    final error = isEdit
        ? await _budgetLimitController.updateBudget(
            _editTarget!.id,
            name: nameController.text,
            limit: limitLocked ? null : limit,
            isFixedPrice: isFixedPrice.value,
          )
        : await _budgetLimitController.createBudget(
            CreateBudgetLimitParams(
              categoryId: selectedCategoryId.value ?? '',
              name: nameController.text,
              limit: limit,
              isFixedPrice: isFixedPrice.value,
            ),
          );

    if (!context.mounted) {
      isSubmitting.value = false;
      return;
    }
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
      isSubmitting.value = false;
      return;
    }

    if (!isEdit) {
      Get.find<GuidelineController>().completeTask('budget_limit');
      if (isFixedPrice.value) {
        Get.find<GuidelineController>().completeTask('min_living');
      }
    }

    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: isEdit
          ? el.tr(CcLocaleKeys.budget_updated, namedArgs: {'name': budgetName})
          : el.tr(CcLocaleKeys.budget_added, namedArgs: {'name': budgetName}),
    );
    Navigator.pop(context);
  }

  void toggleFixedPrice() {
    isFixedPrice.value = !isFixedPrice.value;
  }

  void dismissEstimate() {
    estimatedLimit.value = null;
  }

  void hideKeypad() {
    showKeypad.value = false;
  }

  void onCategorySelected(CategoryEntity cat) {
    selectedCategoryId.value = cat.id;
    nameController.text = el.tr(cat.nameKey);
    estimatedLimit.value = null;
    if (showKeypad.value) showKeypad.value = false;
    _loadEstimate(cat.id);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
