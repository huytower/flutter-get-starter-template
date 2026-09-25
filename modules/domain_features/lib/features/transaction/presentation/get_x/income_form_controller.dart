import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:domain_features/features/category/presentation/get_x/category_settings_controller.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import '../models/unified_category_item.dart';
import 'quick_entry_mixin.dart';
import 'transaction_form_controller.dart';

@injectable
class IncomeFormController extends TransactionFormController
    with QuickEntryMixin {
  IncomeFormController(this._transactionRepository, this._getCategories);

  final TransactionRepository _transactionRepository;
  final GetCategoriesUseCase _getCategories;

  @override
  String get quickEntryCategoryType => CategoryType.income;

  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);

  final RxList<UnifiedCategoryItem> unifiedItems = <UnifiedCategoryItem>[].obs;
  final RxBool isLoadingUnified = false.obs;

  final ScrollController categoryScrollController = ScrollController();

  @override
  final RxInt categoryKey = 0.obs;

  String? _lastSelectedCategoryId;
  final Map<String, GlobalKey> _itemKeys = {};

  GlobalKey getItemKey(int index) {
    // Create a stable key for each item based on its unique ID
    if (index < 0 || index >= unifiedItems.length) {
      return GlobalKey(debugLabel: 'category_item_invalid');
    }
    final itemId = unifiedItems[index].id;
    return _itemKeys.putIfAbsent(itemId, () => GlobalKey(debugLabel: 'category_item_$itemId'));
  }

  final RxList<CategoryEntity> _cachedCategories = <CategoryEntity>[].obs;
  final RxBool isLoadingCategories = false.obs;

  /// Set right before [categoryKey] is bumped by
  /// [QuickEntryMixin.applyQuickEntryCategory], so the remounted
  /// `CategorySelectionSection` resolves and reports back the real
  /// [CategoryEntity] for this id.
  @override
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  final RxList<int> quickAmounts = RxList<int>(MoneyConstants.quickAmounts);

  @override
  void onInit() {
    super.onInit();
    _loadAll();
    initQuickEntry();

    ever(
      CategorySettingsController.onCategoriesChanged,
      (_) => _rebuildUnifiedItems(),
    );

    // Auto-scroll when selection changes
    ever(selectedCategory, (_) => _scrollToSelected());
  }

  Future<void> _loadAll() async {
    isLoadingCategories.value = true;
    isLoadingUnified.value = true;
    await _loadCategories();
    await _loadSuggestions();
    await _loadRecentIncomes();
    await _rebuildUnifiedItems();
    isLoadingCategories.value = false;
    isLoadingUnified.value = false;

    // Auto-select first item if the user hasn't started typing in the AI box
    if (unifiedItems.isNotEmpty &&
        selectedCategory.value == null &&
        !isEditing &&
        quickEntryController.text.isEmpty) {
      final first = unifiedItems.first;
      final cat = getCachedCategoryById(first.categoryId);
      if (cat != null) setCategory(cat);
    }
  }

  Future<void> _loadRecentIncomes() async {
    final result = await _transactionRepository.getTransactions(
      const PaginationRequest(page: 1, itemsPerPage: 100),
    );
    result.when((transactions) {
      _recentIncomes = transactions
          .where((t) => t.type == TransactionType.income)
          .toList();
    }, (_) {});
  }

  List<TransactionEntity> _recentIncomes = [];
  final Map<String, DateTime> _lastRecordedCatTime = {};

  Future<void> _rebuildUnifiedItems() async {
    // Track selected category before rebuild to preserve scroll position
    final selectedId = selectedCategory.value?.id;
    _lastSelectedCategoryId = selectedId;

    final result = await _getCategories();
    final allCats = result.tryGetSuccess() ?? [];
    final incomeCats = allCats
        .where((c) => c.type == CategoryType.income && c.isEnabled)
        .toList();

    // Check if selected category still exists and is enabled
    final selectedCategoryStillExists = incomeCats.any((c) => c.id == selectedId);
    if (!selectedCategoryStillExists && selectedId != null) {
      // Clear selection if category no longer exists or is disabled
      selectedCategory.value = null;
    }

    // Clear old keys that are no longer in the new list
    final newIds = incomeCats.map((c) => 'cat_${c.id}').toSet();
    _itemKeys.removeWhere((id, key) => !newIds.contains(id));

    // Map of CategoryID -> Last used Date
    final lastUsedCat = <String, DateTime>{};

    for (final tx in _recentIncomes) {
      final txTime = DateTime.fromMicrosecondsSinceEpoch(
        int.tryParse(tx.id.split('_').first) ?? tx.date.microsecondsSinceEpoch,
      );
      if (tx.categoryId.isNotEmpty) {
        final current = lastUsedCat[tx.categoryId];
        if (current == null || txTime.isAfter(current)) {
          lastUsedCat[tx.categoryId] = txTime;
        }
      }
    }

    _lastRecordedCatTime.forEach((catId, time) {
      final current = lastUsedCat[catId];
      if (current == null || time.isAfter(current)) {
        lastUsedCat[catId] = time;
      }
    });

    final items = <UnifiedCategoryItem>[];

    for (final c in incomeCats) {
      final lastActivity = lastUsedCat[c.id] ?? DateTime(2000);
      items.add(
        UnifiedCategoryItem(
          id: 'cat_${c.id}',
          categoryId: c.id,
          nameKey: c.nameKey,
          iconCode: c.iconCode,
          iconFamily: c.iconFamily,
          lastActivityAt: lastActivity,
          isBudget: false,
        ),
      );
    }

    // Sort by lastActivityAt descending
    items.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));

    unifiedItems.assignAll(items);

    // Scroll to selected category after rebuild if it still exists
    if (selectedCategoryStillExists && selectedId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    } else if (!selectedCategoryStillExists) {
      // Reset scroll to start if selected category no longer exists
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (categoryScrollController.hasClients) {
          categoryScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  void _scrollToSelected() {
    if (unifiedItems.isEmpty) return;
    final category = selectedCategory.value;
    if (category == null) return;

    final index = unifiedItems.indexWhere(
      (item) => !item.isBudget && item.categoryId == category.id,
    );

    if (index != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!categoryScrollController.hasClients) return;

        final key = getItemKey(index);
        if (key == null) return;

        final context = key.currentContext;
        if (context == null) return;

        // Use Scrollable.ensureVisible for accurate, responsive positioning
        // This automatically handles actual widget dimensions and layout
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.5, // Center the item
        );
      });
    }
  }

  Future<void> _loadCategories() async {
    final result = await _getCategories();
    result.when((categories) {
      _cachedCategories.assignAll(categories);
    }, (error) {});
  }

  CategoryEntity? getCachedCategoryById(String id) {
    return _cachedCategories.firstWhereOrNull((c) => c.id == id);
  }

  @override
  void onClose() {
    categoryScrollController.dispose();
    disposeQuickEntry();
    super.onClose();
  }

  Future<void> _loadSuggestions() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    quickAmounts.assignAll(
      MoneyConstants.getIncomeSuggestions(settings.birthYear),
    );
  }

  @override
  bool get canSubmit =>
      selectedCategory.value != null &&
      selectedWalletId.value != null &&
      amountStr.value != '0' &&
      amountStr.value.isNotEmpty;

  @override
  void applyResolvedCategory(CategoryEntity category) {
    selectedCategory.value = category;
  }

  @override
  Future<void> onReset() async {
    selectedCategory.value = null;
    categoryKey.value++;
    resetQuickEntry();
    await _rebuildUnifiedItems();
  }

  @override
  void clearCategorySelection() {
    selectedCategory.value = null;
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    // Manual selection clears any pending prefill from AI suggestions so it
    // doesn't clobber the user's choice on the next rebuild.
    pendingPrefillCategoryId.value = null;
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final categoryId = selectedCategory.value?.id ?? '';
    final categoryLabel = selectedCategory.value != null
        ? el.tr(selectedCategory.value!.nameKey)
        : '';
    final amount = int.tryParse(amountStr.value) ?? 0;

    final lastCategory = selectedCategory.value;
    if (categoryId.isNotEmpty)
      _lastRecordedCatTime[categoryId] = DateTime.now();

    final result = isEditing
        ? await getIt<UpdateTransactionUseCase>().call(
            UpdateTransactionParams(
              original: editingTransaction!,
              amount: amount,
              categoryId: categoryId,
              categoryLabel: categoryLabel,
              categoryIconCode: selectedCategory.value?.iconCode,
              categoryIconFamily: selectedCategory.value?.iconFamily,
              walletId: selectedWalletId.value ?? '',
              note: composeNote(),
              date: date.value,
            ),
          )
        : await getIt<CreateTransactionUseCase>().call(
            CreateTransactionParams(
              type: TransactionType.income,
              amount: amount,
              categoryId: categoryId,
              categoryLabel: categoryLabel,
              categoryIconCode: selectedCategory.value?.iconCode,
              categoryIconFamily: selectedCategory.value?.iconFamily,
              walletId: selectedWalletId.value ?? '',
              note: composeNote(),
              date: date.value,
            ),
          );
    isSubmitting.value = false;

    result.when(
      (_) async {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            isEditing
                ? CcLocaleKeys.transaction_income_updated
                : CcLocaleKeys.transaction_income_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        if (isEditing) {
          onEditSaved?.call();
        } else {
          await resetForm();
          if (lastCategory != null) {
            setCategory(lastCategory);
            // Reset scroll to start since the category is now at index 0
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (categoryScrollController.hasClients) {
                categoryScrollController.jumpTo(0);
              }
            });
          }
        }
        await refreshParent();
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
