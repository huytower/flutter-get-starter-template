import 'dart:async';

import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/budget_limit/export_budget_limit.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/budget_over_limit_helper.dart';
import '../../../../core/helper/location_suggestion_helper.dart';
import '../../../../core/helper/merchant_match_helper.dart';
import '../../../../core/helper/monthly_bill_suggestion_helper.dart';
import '../../../../core/helper/time_based_suggestion_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../notification/domain/usecases/check_budget_threshold_usecase.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import '../models/unified_category_item.dart';
import 'quick_entry_mixin.dart';
import 'transaction_form_controller.dart';

@injectable
class ExpenseFormController extends TransactionFormController
    with QuickEntryMixin {
  ExpenseFormController(this._transactionRepository, this._getCategories);

  final TransactionRepository _transactionRepository;
  final GetCategoriesUseCase _getCategories;

  // Use getIt for additional dependencies to avoid DI module mismatches
  // until a full build_runner run is completed.
  GetBudgetLimitStatsUseCase get _getBudgetStats =>
      getIt<GetBudgetLimitStatsUseCase>();

  @override
  String get quickEntryCategoryType => CategoryType.expense;

  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final Rx<BudgetLimitEntity?> selectedBudget = Rx<BudgetLimitEntity?>(null);

  final RxList<UnifiedCategoryItem> unifiedItems = <UnifiedCategoryItem>[].obs;
  final RxBool isLoadingUnified = false.obs;

  final ScrollController categoryScrollController = ScrollController();

  @override
  final RxInt categoryKey = 0.obs;

  final RxList<CategoryEntity> _cachedCategories = <CategoryEntity>[].obs;
  final RxBool isLoadingCategories = false.obs;

  @override
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  String? timeBasedSuggestedCategoryId;

  final Rx<TransactionEntity?> merchantMatchSuggestion = Rx<TransactionEntity?>(
    null,
  );

  final Rx<TransactionEntity?> locationMatchSuggestion = Rx<TransactionEntity?>(
    null,
  );

  final Rx<TransactionEntity?> billMatchSuggestion = Rx<TransactionEntity?>(
    null,
  );

  double? _currentLat;
  double? _currentLng;

  TransactionEntity? _lastLocationMatch;
  TransactionEntity? _lastBillMatch;

  List<TransactionEntity> _recentExpenses = [];
  Timer? _merchantMatchDebounce;

  @override
  bool get canSubmit =>
      selectedCategory.value != null &&
      selectedWalletId.value != null &&
      amountStr.value != '0' &&
      amountStr.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadAll();

    noteController.addListener(_onNoteChanged);
    initQuickEntry();

    // Handle AI category suggestions by resolving to a budget if possible
    ever(pendingPrefillCategoryId, (String? categoryId) {
      if (categoryId != null) {
        // Try to find a budget for this category first (highest priority)
        final budgetMatch = unifiedItems.firstWhereOrNull(
          (item) => item.isBudget && item.categoryId == categoryId,
        );
        if (budgetMatch != null) {
          final budget = _findBudgetById(budgetMatch.budgetId!);
          if (budget != null) {
            selectedBudget.value = budget;
            return;
          }
        }
      }
    });

    if (Get.isRegistered<BudgetLimitController>()) {
      ever(
        Get.find<BudgetLimitController>().budgets,
        (_) => _rebuildUnifiedItems(),
      );
    }

    // Auto-scroll when selection changes
    everAll([selectedCategory, selectedBudget], (_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    if (unifiedItems.isEmpty) return;

    final budget = selectedBudget.value;
    final category = selectedCategory.value;

    int index = -1;
    if (budget != null) {
      index = unifiedItems.indexWhere(
        (item) => item.isBudget && item.budgetId == budget.id,
      );
    } else if (category != null) {
      index = unifiedItems.indexWhere(
        (item) => !item.isBudget && item.categoryId == category.id,
      );
    }

    if (index != -1) {
      // Small delay to ensure the UI has finished updating
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!categoryScrollController.hasClients) return;

        final double itemWidth = 85.0; // context.respDim(85) equivalent logic
        final double spacing = 8.0; // context.respDim(8)
        final double targetOffset = index * (itemWidth + spacing);

        final double viewportWidth =
            categoryScrollController.position.viewportDimension;
        final double centeredOffset =
            targetOffset - (viewportWidth / 2) + (itemWidth / 2);

        categoryScrollController.animateTo(
          centeredOffset.clamp(
            0,
            categoryScrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  BudgetLimitEntity? _findBudgetById(String id) {
    return budgets.firstWhereOrNull((b) => b.budget.id == id)?.budget;
  }

  List<BudgetLimitStatsEntity> get budgets {
    if (Get.isRegistered<BudgetLimitController>()) {
      return Get.find<BudgetLimitController>().budgets;
    }
    return [];
  }

  Future<void> _loadAll() async {
    isLoadingCategories.value = true;
    isLoadingUnified.value = true;
    await _loadCategories();
    await _loadRecentExpenses();
    await _rebuildUnifiedItems();
    isLoadingCategories.value = false;
    isLoadingUnified.value = false;

    refreshTimeBasedSuggestion();

    // Only auto-select first item if the user hasn't started typing in the AI box
    if (unifiedItems.isNotEmpty &&
        selectedBudget.value == null &&
        selectedCategory.value == null &&
        !isEditing &&
        quickEntryController.text.isEmpty) {
      final first = unifiedItems.first;
      if (first.isBudget) {
        final budget = _findBudgetById(first.budgetId!);
        if (budget != null) setBudget(budget);
      } else {
        final cat = getCachedCategoryById(first.categoryId);
        if (cat != null) setCategory(cat);
      }
    }
  }

  Future<void> _rebuildUnifiedItems() async {
    final result = await _getCategories();
    final allCats = result.tryGetSuccess() ?? [];
    final expenseCats = allCats
        .where((c) => c.type == CategoryType.expense && c.isEnabled)
        .toList();

    List<BudgetLimitStatsEntity> currentBudgets = [];
    if (Get.isRegistered<BudgetLimitController>()) {
      currentBudgets = Get.find<BudgetLimitController>().budgets;
    } else {
      final statsResult = await _getBudgetStats.call();
      currentBudgets = statsResult.tryGetSuccess() ?? [];
    }

    // Map of CategoryID -> Last used Date
    // Map of BudgetID -> Last used Date
    final lastUsedCat = <String, DateTime>{};
    final lastUsedBudget = <String, DateTime>{};

    for (final tx in _recentExpenses) {
      if (tx.categoryId.isNotEmpty) {
        final current = lastUsedCat[tx.categoryId];
        if (current == null || tx.date.isAfter(current)) {
          lastUsedCat[tx.categoryId] = tx.date;
        }
      }
      if (tx.budgetId != null && tx.budgetId!.isNotEmpty) {
        final current = lastUsedBudget[tx.budgetId!];
        if (current == null || tx.date.isAfter(current)) {
          lastUsedBudget[tx.budgetId!] = tx.date;
        }
      }
    }

    final items = <UnifiedCategoryItem>[];
    final budgetCategoryIds = <String>{};

    // Add Budgets
    for (final b in currentBudgets) {
      budgetCategoryIds.add(b.budget.categoryId);
      // Use DateTime(2000) as fallback if no activity, since Entity lacks updatedAt
      final lastActivity = lastUsedBudget[b.budget.id] ?? DateTime(2000);
      items.add(
        UnifiedCategoryItem(
          id: 'budget_${b.budget.id}',
          budgetId: b.budget.id,
          categoryId: b.budget.categoryId,
          displayName: b.budget.name,
          iconCode: b.iconCode,
          iconFamily: b.iconFamily,
          lastActivityAt: lastActivity,
          isBudget: true,
        ),
      );
    }

    // Add Categories (only if they don't have a specific budget)
    for (final c in expenseCats) {
      if (budgetCategoryIds.contains(c.id)) continue;

      final lastActivity = lastUsedCat[c.id] ?? DateTime(2000);
      items.add(
        UnifiedCategoryItem(
          id: 'cat_${c.id}',
          categoryId: c.id,
          displayName: el.tr(c.nameKey),
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
    _merchantMatchDebounce?.cancel();
    noteController.removeListener(_onNoteChanged);
    categoryScrollController.dispose();
    disposeQuickEntry();
    super.onClose();
  }

  @override
  void applyResolvedCategory(CategoryEntity category) {
    selectedCategory.value = category;
    selectedBudget.value = null; // Clear existing budget selection first

    // Try to auto-resolve to a budget if possible.
    // In the unified list, we prefer a budget if one exists for this category.
    final budgetMatch = unifiedItems.firstWhereOrNull(
      (item) => item.isBudget && item.categoryId == category.id,
    );
    if (budgetMatch != null) {
      selectedBudget.value = _findBudgetById(budgetMatch.budgetId!);
    }
  }

  @override
  void onReset() {
    selectedCategory.value = null;
    selectedBudget.value = null;
    merchantMatchSuggestion.value = null;
    resetQuickEntry();
    refreshTimeBasedSuggestion();
    categoryKey.value++;
    refreshLocationSuggestion();
    _rebuildUnifiedItems();
  }

  @override
  void clearCategorySelection() {
    selectedCategory.value = null;
    selectedBudget.value = null;
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    selectedBudget.value = null;

    // Prefer the most recently used budget for this category if multiple exist
    final budgetMatch = unifiedItems.firstWhereOrNull(
      (item) => item.isBudget && item.categoryId == category.id,
    );
    if (budgetMatch != null) {
      selectedBudget.value = _findBudgetById(budgetMatch.budgetId!);
    }

    pendingPrefillCategoryId.value = null;
  }

  void setBudget(BudgetLimitEntity budget) {
    selectedBudget.value = budget;
    // When a budget is picked, its category is automatically selected
    final category = getCachedCategoryById(budget.categoryId);
    if (category != null) {
      selectedCategory.value = category;
    }
    pendingPrefillCategoryId.value = null;
    categoryKey.value++;
  }

  void refreshTimeBasedSuggestion() {
    timeBasedSuggestedCategoryId = suggestExpenseCategoryIdForHour(
      DateTime.now().hour,
    );
  }

  Future<void> _loadRecentExpenses() async {
    final result = await _transactionRepository.getTransactions(
      const PaginationRequest(page: 1, itemsPerPage: 100),
    );
    result.when((transactions) {
      _recentExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .toList();
    }, (_) {});
  }

  void _onNoteChanged() {
    _merchantMatchDebounce?.cancel();
    _merchantMatchDebounce = Timer(
      const Duration(milliseconds: 400),
      _runMerchantMatch,
    );
  }

  void _runMerchantMatch() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return;
    }
    final candidates = _recentExpenses
        .where((t) => (t.note ?? '').trim().isNotEmpty)
        .toList();
    final match = findBestMerchantMatch(
      query: noteController.text,
      candidates: candidates,
    );
    merchantMatchSuggestion.value = match;
    _publishFallbackSuggestions();
  }

  void dismissMerchantMatch() {
    merchantMatchSuggestion.value = null;
    _publishFallbackSuggestions();
  }

  /// Pre-fills category/amount/wallet from the fuzzy-matched past expense —
  /// same "prefill, user still confirms" contract as [applyTemplate].
  void applyMerchantMatch(TransactionEntity match) {
    amountStr.value = match.amount.toString();
    if (wallets.any((w) => w.id == match.walletId)) {
      selectedWalletId.value = match.walletId;
    }
    pendingPrefillCategoryId.value = match.categoryId;
    categoryKey.value++;
    merchantMatchSuggestion.value = null;
    locationMatchSuggestion.value = null;
    billMatchSuggestion.value = null;
  }

  Future<void> refreshLocationSuggestion() async {
    locationMatchSuggestion.value = null;
    _lastLocationMatch = null;
    _currentLat = null;
    _currentLng = null;
    billMatchSuggestion.value = null;
    _lastBillMatch = null;
    await _loadRecentExpenses();
    await _loadLocationSuggestion();
    _loadMonthlyBillSuggestion();
  }

  Future<void> _loadLocationSuggestion() async {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return;
    }

    final lastKnown = await CcLocationHelper.getLastKnownPosition();
    if (lastKnown != null) {
      _applyLocationFix(lastKnown.latitude, lastKnown.longitude);
    }

    final position = await CcLocationHelper.getCurrentPosition();
    if (position != null) {
      _applyLocationFix(position.latitude, position.longitude);
    }
  }

  void _applyLocationFix(double lat, double lng) {
    _currentLat = lat;
    _currentLng = lng;

    final candidates = _recentExpenses
        .where((t) => t.lat != null && t.lng != null)
        .toList();

    _lastLocationMatch = findNearbyExpenseMatch(
      lat: lat,
      lng: lng,
      candidates: candidates,
    );
    _publishFallbackSuggestions();
  }

  void _loadMonthlyBillSuggestion() {
    if (!getIt<UserLevelController>().status.value.canUseAiSmartEntry) {
      return;
    }

    _lastBillMatch = findMonthlyBillMatch(
      now: DateTime.now(),
      candidates: _recentExpenses,
    );
    _publishFallbackSuggestions();
  }

  void _publishFallbackSuggestions() {
    if (merchantMatchSuggestion.value == null) {
      locationMatchSuggestion.value = _lastLocationMatch;
      billMatchSuggestion.value = _lastBillMatch;
    }
  }

  void dismissLocationMatch() {
    locationMatchSuggestion.value = null;
  }

  void dismissBillMatch() {
    billMatchSuggestion.value = null;
  }

  void applyLocationMatch(TransactionEntity match) {
    amountStr.value = match.amount.toString();
    if (wallets.any((w) => w.id == match.walletId)) {
      selectedWalletId.value = match.walletId;
    }
    pendingPrefillCategoryId.value = match.categoryId;
    categoryKey.value++;
    locationMatchSuggestion.value = null;
    _lastLocationMatch = null;
  }

  void applyBillMatch(TransactionEntity match) {
    amountStr.value = match.amount.toString();
    if (wallets.any((w) => w.id == match.walletId)) {
      selectedWalletId.value = match.walletId;
    }
    pendingPrefillCategoryId.value = match.categoryId;
    categoryKey.value++;
    billMatchSuggestion.value = null;
    _lastBillMatch = null;
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final categoryId = selectedCategory.value?.id ?? '';
    final categoryLabel = selectedBudget.value != null
        ? selectedBudget.value!.name
        : selectedCategory.value != null
        ? el.tr(selectedCategory.value!.nameKey)
        : '';
    final amount = int.tryParse(amountStr.value) ?? 0;

    final result = isEditing
        ? await getIt<UpdateTransactionUseCase>().call(
            UpdateTransactionParams(
              original: editingTransaction!,
              amount: amount,
              categoryId: categoryId,
              categoryLabel: categoryLabel,
              categoryIconCode: selectedCategory.value?.iconCode,
              categoryIconFamily: selectedCategory.value?.iconFamily,
              budgetId: selectedBudget.value?.id,
              walletId: selectedWalletId.value ?? '',
              note: composeNote(),
              date: date.value,
            ),
          )
        : await getIt<CreateTransactionUseCase>().call(
            CreateTransactionParams(
              type: TransactionType.expense,
              amount: amount,
              categoryId: categoryId,
              categoryLabel: categoryLabel,
              categoryIconCode: selectedCategory.value?.iconCode,
              categoryIconFamily: selectedCategory.value?.iconFamily,
              budgetId: selectedBudget.value?.id,
              walletId: selectedWalletId.value ?? '',
              note: composeNote(),
              date: date.value,
              lat: _currentLat,
              lng: _currentLng,
            ),
          );
    isSubmitting.value = false;

    result.when(
      (_) async {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );

        BudgetOverLimitEntity? overLimit;
        if (categoryId.isNotEmpty) {
          final overResult = await getIt<GetBudgetOverLimitCountUseCase>().call(
            categoryId,
          );
          overLimit = overResult.tryGetSuccess();
        }

        if (categoryId.isNotEmpty && !isEditing) {
          getIt<CheckBudgetThresholdUseCase>().call(
            categoryId: categoryId,
            transactionAmount: amount,
          );
        }
        if (!context.mounted) return;

        if (overLimit != null) {
          CcSnackBarHelper.showSnackBar(
            context: context,
            message: el.tr(
              CcLocaleKeys.budget_over_limit_count,
              namedArgs: {
                'name': overLimit.budgetName,
                'count': '${overLimit.count}',
              },
            ),
            textColor: budgetOverLimitColor(
              overLimit.count,
              context.ccColorScheme,
            ),
          );
        } else {
          CcSnackBarHelper.showSuccessSnackBar(
            context: context,
            message: el.tr(
              isEditing
                  ? CcLocaleKeys.transaction_expense_updated
                  : CcLocaleKeys.transaction_expense_saved,
              namedArgs: {'amount': savedAmount},
            ),
          );
        }
        if (isEditing) {
          onEditSaved?.call();
        } else {
          resetForm();
        }
        await refreshParent();
        // Guideline: first_transaction completed
        Get.find<GuidelineController>().completeTask('first_transaction');
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
