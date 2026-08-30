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
import 'quick_entry_mixin.dart';
import 'transaction_form_controller.dart';

@injectable
class ExpenseFormController extends TransactionFormController
    with QuickEntryMixin {
  ExpenseFormController(this._transactionRepository, this._getCategories);

  final TransactionRepository _transactionRepository;
  final GetCategoriesUseCase _getCategories;

  @override
  String get quickEntryCategoryType => CategoryType.expense;

  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final Rx<BudgetLimitEntity?> selectedBudget = Rx<BudgetLimitEntity?>(null);

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
      if (categoryId != null && Get.isRegistered<BudgetLimitController>()) {
        final budgets = Get.find<BudgetLimitController>().budgets;
        final matches = budgets.where((b) => b.budget.categoryId == categoryId);
        if (matches.length == 1) {
          selectedBudget.value = matches.first.budget;
        }
      }
    });
  }

  Future<void> _loadAll() async {
    isLoadingCategories.value = true;
    await _loadCategories();
    isLoadingCategories.value = false;

    refreshTimeBasedSuggestion();

    // Auto-select first budget if available and nothing is selected yet
    if (Get.isRegistered<BudgetLimitController>()) {
      final budgetController = Get.find<BudgetLimitController>();
      if (budgetController.budgets.isNotEmpty &&
          selectedBudget.value == null &&
          selectedCategory.value == null &&
          !isEditing) {
        setBudget(budgetController.budgets.first.budget);
      }

      // Also listen for changes (e.g. first budget created)
      once(budgetController.budgets, (budgets) {
        if (budgets.isNotEmpty &&
            selectedBudget.value == null &&
            selectedCategory.value == null &&
            !isEditing) {
          setBudget(budgets.first.budget);
        }
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
    _merchantMatchDebounce?.cancel();
    noteController.removeListener(_onNoteChanged);
    disposeQuickEntry();
    super.onClose();
  }

  @override
  void applyResolvedCategory(CategoryEntity category) {
    selectedCategory.value = category;

    // Also try to auto-resolve to a budget if possible
    if (Get.isRegistered<BudgetLimitController>()) {
      final budgets = Get.find<BudgetLimitController>().budgets;
      final matches = budgets.where((b) => b.budget.categoryId == category.id);
      if (matches.length == 1) {
        selectedBudget.value = matches.first.budget;
      }
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
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    selectedBudget.value = null;

    // If we're in budget-picker mode, try to auto-resolve to a budget
    if (Get.isRegistered<BudgetLimitController>()) {
      final budgets = Get.find<BudgetLimitController>().budgets;
      final matches = budgets.where((b) => b.budget.categoryId == category.id);
      if (matches.length == 1) {
        selectedBudget.value = matches.first.budget;
      }
    }

    // Manual selection clears any pending prefill from AI suggestions
    // so it doesn't clobber the user's choice on the next rebuild.
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
