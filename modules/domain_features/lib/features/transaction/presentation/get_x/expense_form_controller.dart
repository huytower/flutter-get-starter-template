import 'dart:async';

import 'package:cc_sdk_data/data/models/pagination_request.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/budget_limit/export_budget_limit.dart';
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../guideline/guideline_controller.dart';
import '../../../../core/di/di.dart';
import '../../../../core/helper/budget_over_limit_helper.dart';
import '../../../../core/helper/merchant_match_helper.dart';
import '../../../../core/helper/time_based_suggestion_helper.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../notification/domain/usecases/check_budget_threshold_usecase.dart';
import '../../../transaction_template/domain/entities/transaction_template_entity.dart';
import '../../../user_level/presentation/get_x/user_level_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import 'transaction_form_controller.dart';

@injectable
class ExpenseFormController extends TransactionFormController {
  ExpenseFormController(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final RxInt categoryKey = 0.obs;

  /// Set right before [categoryKey] is bumped by [applyTemplate] or
  /// [applyMerchantMatch], so the remounted `CategorySelectionSection`
  /// resolves and reports back the real [CategoryEntity] for this id — same
  /// mechanism edit-mode already uses via `editingTransaction?.categoryId`.
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  /// Phase 3.2 time-based suggestion (see [suggestExpenseCategoryIdForHour])
  /// — recomputed on every fresh blank form (init + after each reset) so it
  /// always reflects "now", not just whenever this singleton was created.
  /// Lowest priority in `_buildCategorySection`'s fallback chain — a template,
  /// merchant match, or an in-progress edit always wins.
  String? timeBasedSuggestedCategoryId;

  /// Phase 3.3 "AI Autofill" — the best fuzzy match (see
  /// [findBestMerchantMatch]) against the note text typed so far, offered as
  /// a one-tap suggestion. Null hides the suggestion affordance.
  final Rx<TransactionEntity?> merchantMatchSuggestion =
      Rx<TransactionEntity?>(null);

  List<TransactionEntity> _recentExpenseCandidates = [];
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
    timeBasedSuggestedCategoryId = suggestExpenseCategoryIdForHour(
      DateTime.now().hour,
    );
    noteController.addListener(_onNoteChanged);
    _loadRecentExpenseCandidates();
  }

  @override
  void onClose() {
    _merchantMatchDebounce?.cancel();
    noteController.removeListener(_onNoteChanged);
    super.onClose();
  }

  @override
  void onReset() {
    selectedCategory.value = null;
    pendingPrefillCategoryId.value = null;
    merchantMatchSuggestion.value = null;
    timeBasedSuggestedCategoryId = suggestExpenseCategoryIdForHour(
      DateTime.now().hour,
    );
    categoryKey.value++;
    // The just-submitted transaction should be matchable for the very next
    // entry in this same session.
    _loadRecentExpenseCandidates();
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
  }

  /// Pre-fills category/amount/wallet from a quick-entry template — the user
  /// still taps the form's own Save button to confirm, matching how edit
  /// mode and every other pre-fill flow in this app works.
  void applyTemplate(TransactionTemplateEntity template) {
    amountStr.value = template.amount.toString();
    if (wallets.any((w) => w.id == template.walletId)) {
      selectedWalletId.value = template.walletId;
    }
    pendingPrefillCategoryId.value = template.categoryId;
    categoryKey.value++;
  }

  Future<void> _loadRecentExpenseCandidates() async {
    final result = await _transactionRepository.getTransactions(
      const PaginationRequest(page: 1, itemsPerPage: 100),
    );
    result.when((transactions) {
      _recentExpenseCandidates = transactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                (t.note ?? '').trim().isNotEmpty,
          )
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
    final match = findBestMerchantMatch(
      query: noteController.text,
      candidates: _recentExpenseCandidates,
    );
    merchantMatchSuggestion.value = match;
  }

  void dismissMerchantMatch() {
    merchantMatchSuggestion.value = null;
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
              type: TransactionType.expense,
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

        BudgetOverLimitEntity? overLimit;
        if (categoryId.isNotEmpty) {
          final overResult = await getIt<GetBudgetOverLimitCountUseCase>()
              .call(categoryId);
          overLimit = overResult.tryGetSuccess();
        }
        // Phase 3.4 threshold notifications — new expenses only; an edit's
        // before/after spend delta isn't simply the edited amount, so
        // recomputing a correct crossing for edits is left for later.
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
        refreshParent();
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
