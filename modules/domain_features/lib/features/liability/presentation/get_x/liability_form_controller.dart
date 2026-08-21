import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../guideline/guideline_controller.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';
import '../../domain/usecases/create_liability_usecase.dart';
import '../../domain/usecases/get_liability_balances_usecase.dart';
import '../../domain/usecases/record_liability_payment_usecase.dart';
import '../../domain/usecases/schedule_liability_reminders_usecase.dart';
import '../get_x/liability_base_form_controller.dart';
import '../get_x/liability_list_controller.dart';

/// One editable row of an installment schedule being built in the liability
/// creation form. Presentation-only — converted to [LiabilityInstallmentEntity]
/// at submit time.
class LoanInstallmentDraft {
  final Rx<DateTime> dueDate;
  final TextEditingController amountController = TextEditingController();
  final RxInt amount = 0.obs;

  LoanInstallmentDraft(DateTime initialDueDate) : dueDate = initialDueDate.obs;

  void setAmount(String value) {
    amount.value = int.tryParse(value) ?? 0;
  }

  void dispose() {
    amountController.dispose();
  }
}

enum LiabilityAction { initiate, settle }

/// Consolidated Liability form: handles recording transactions against
/// existing loans (Repay) or completing a new loan's details (Borrow).
@lazySingleton
class LiabilityFormController extends LiabilityBaseFormController {
  @override
  String get quickEntryCategoryType => CategoryType.debtLoan;

  @override
  List<String> get quickEntryCategoryGroupIds => [
    CategorySeed.debtLoanBorrowGroupId,
  ];

  @override
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  final String direction = LiabilityDirection.borrow;
  final Rx<LiabilityAction> action = LiabilityAction.initiate.obs;

  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  @override
  final RxInt categoryKey = 0.obs;
  final RxString repaymentMethod = LiabilityRepaymentMethod.lumpSum.obs;
  final Rx<DateTime?> finalDueDate = Rx<DateTime?>(null);
  final RxList<LoanInstallmentDraft> installmentDrafts =
      <LoanInstallmentDraft>[].obs;
  final RxBool reminderBeforeDueDate = false.obs;

  final RxList<LiabilityBalanceEntity> loanBalances =
      <LiabilityBalanceEntity>[].obs;
  final RxList<LiabilityBalanceEntity> mergedItems =
      <LiabilityBalanceEntity>[].obs;
  final RxBool isLoadingMerged = true.obs;
  final RxnString selectedLoanId = RxnString();

  final RxnInt editingInstallmentIndex = RxnInt();
  final RxBool isVip = false.obs;

  int get principalAmount => int.tryParse(amountStr.value) ?? 0;

  int get installmentsTotal =>
      installmentDrafts.fold(0, (sum, d) => sum + d.amount.value);

  bool get canAddInstallment =>
      principalAmount > 0 && installmentsTotal < principalAmount;

  @override
  void onInit() {
    super.onInit();
    _loadAll();

    // Listen to liability list changes to sync with deletions from list page
    if (Get.isRegistered<LiabilityListController>()) {
      final listController = Get.find<LiabilityListController>();
      ever(listController.loans, (_) {
        loadLiabilities();
      });
    }
  }

  @override
  bool get canSubmit {
    if (selectedLoanId.value == null) return false;
    if (amountStr.value == '0' || amountStr.value.isEmpty) return false;
    if (selectedWalletId.value == null) return false;

    final loan = mergedItems
        .firstWhereOrNull((b) => b.liability.id == selectedLoanId.value)
        ?.liability;
    if (loan == null) return false;

    if (loan.principalAmount == 0) {
      if (repaymentMethod.value == LiabilityRepaymentMethod.installment) {
        if (installmentDrafts.isEmpty) return false;
        if (installmentsTotal != principalAmount) return false;
        return installmentDrafts.every((d) => d.amount.value > 0);
      }
      return finalDueDate.value != null;
    }

    return true;
  }

  Future<void> _loadAll() async {
    isLoadingMerged.value = true;
    await _loadVipStatus();
    await loadLiabilities();
    isLoadingMerged.value = false;
    initQuickEntry();
  }

  Future<void> loadLiabilities() async {
    final result = await getIt<GetLiabilityBalancesUseCase>().call();
    result.when((balances) {
      loanBalances.assignAll(balances);
      final filtered = balances.where((b) => b.liability.isBorrow).toList();

      filtered.sort(
        (a, b) => b.liability.updatedAt.compareTo(a.liability.updatedAt),
      );

      mergedItems.assignAll(filtered);

      if (selectedLoanId.value != null) {
        final stillExists = mergedItems.any(
          (b) => b.liability.id == selectedLoanId.value,
        );
        if (!stillExists) {
          selectedLoanId.value = null;
          selectedCategory.value = null;
        }
      }

      if (selectedLoanId.value == null && mergedItems.isNotEmpty) {
        selectLoan(mergedItems.first);
      }
    }, (_) {});
  }

  @override
  void selectLoan(LiabilityBalanceEntity balance) {
    if (selectedLoanId.value == balance.liability.id) return;

    selectedLoanId.value = balance.liability.id;

    // Only auto-default the wallet if the user hasn't selected one yet.
    // This allows flexible cross-wallet borrowing/repayment.
    if (selectedWalletId.value == null) {
      selectedWalletId.value = balance.liability.walletId;
    }

    // Reset amount to avoid carry-over from previous selection
    amountStr.value = '0';

    debugPrint(
      '[LIABILITY_FORM] selectLoan: id=${balance.liability.id}, walletId=${balance.liability.walletId}',
    );

    _loadCategoryForLoan(balance.liability.categoryId);

    if (balance.liability.principalAmount > 0) {
      installmentDrafts.clear();
      finalDueDate.value = null;
    }
  }

  Future<void> _loadCategoryForLoan(String categoryId) async {
    final result = await getIt<GetCategoriesUseCase>().call();
    result.when((categories) {
      selectedCategory.value = categories.firstWhereOrNull(
        (c) => c.id == categoryId,
      );
    }, (_) {});
  }

  Future<void> _loadVipStatus() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    isVip.value = settings.isVip;
  }

  @override
  void onClose() {
    for (final draft in installmentDrafts) {
      draft.dispose();
    }
    disposeQuickEntry();
    super.onClose();
  }

  @override
  void setAction(LiabilityAction value) {
    if (action.value == value) return;
    action.value = value;
    // We no longer clear selection or reload because both sub-segments
    // share the exact same list of categories/loans.
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    pendingPrefillCategoryId.value = null;
  }

  void setRepaymentMethod(String value) {
    repaymentMethod.value = value;
  }

  void setReminderBeforeDueDate(bool value) {
    reminderBeforeDueDate.value = value;
  }

  Future<void> pickFinalDueDate(BuildContext context) async {
    final picked = await _pickFutureDate(
      context,
      finalDueDate.value ?? DateTime.now(),
    );
    if (picked != null) finalDueDate.value = picked;
  }

  Future<void> pickInstallmentDueDate(BuildContext context, int index) async {
    final draft = installmentDrafts[index];
    final picked = await _pickFutureDate(context, draft.dueDate.value);
    if (picked != null) draft.dueDate.value = picked;
  }

  Future<DateTime?> _pickFutureDate(
    BuildContext context,
    DateTime initial,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return TransactionFormHelpers.pickDate(
      context,
      initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: DateTime(now.year + 10),
    );
  }

  void addInstallmentPeriod() {
    if (!canAddInstallment) return;

    final DateTime lastDate;
    if (installmentDrafts.isNotEmpty) {
      lastDate = installmentDrafts.last.dueDate.value;
    } else {
      lastDate = date.value;
    }

    final remaining = principalAmount - installmentsTotal;
    var defaultAmount = installmentDrafts.isNotEmpty
        ? installmentDrafts.first.amount.value
        : 0;
    if (defaultAmount > remaining) defaultAmount = remaining;

    final nextDate = DateTime(lastDate.year, lastDate.month + 1, lastDate.day);

    final newDraft = LoanInstallmentDraft(nextDate);
    newDraft.amount.value = defaultAmount;

    installmentDrafts.add(newDraft);
  }

  void removeInstallmentPeriod(int index) {
    installmentDrafts.removeAt(index).dispose();
    if (editingInstallmentIndex.value == index) {
      hideKeypad();
    }
  }

  @override
  void handleKeyPress(String key) {
    if (editingInstallmentIndex.value != null) {
      final index = editingInstallmentIndex.value!;
      if (index >= installmentDrafts.length) return;

      final draft = installmentDrafts[index];
      String current = draft.amount.value.toString();
      if (current == '0') {
        if (key != '0' && key != '000') current = key;
      } else {
        current += key;
      }

      draft.amount.value = int.tryParse(current) ?? 0;
    } else {
      super.handleKeyPress(key);
    }
  }

  @override
  void handleDelete() {
    if (editingInstallmentIndex.value != null) {
      final index = editingInstallmentIndex.value!;
      if (index >= installmentDrafts.length) return;

      final draft = installmentDrafts[index];
      String current = draft.amount.value.toString();
      if (current.length > 1) {
        current = current.substring(0, current.length - 1);
      } else {
        current = '0';
      }
      draft.amount.value = int.tryParse(current) ?? 0;
    } else {
      super.handleDelete();
    }
  }

  void handleClear() {
    if (editingInstallmentIndex.value != null) {
      final index = editingInstallmentIndex.value!;
      if (index >= installmentDrafts.length) return;
      installmentDrafts[index].amount.value = 0;
    } else {
      amountStr.value = '0';
    }
  }

  void handleSuggestion(int value) {
    if (editingInstallmentIndex.value != null) {
      final index = editingInstallmentIndex.value!;
      if (index >= installmentDrafts.length) return;
      installmentDrafts[index].amount.value = value;
    } else {
      amountStr.value = value.toString();
    }
  }

  void showKeypadForInstallment(BuildContext context, int index) {
    editingInstallmentIndex.value = index;
    showKeypadAndScroll(context);
  }

  @override
  void hideKeypad() {
    super.hideKeypad();
    editingInstallmentIndex.value = null;
  }

  @override
  void onReset() {
    selectedCategory.value = null;
    categoryKey.value++;
    repaymentMethod.value = LiabilityRepaymentMethod.lumpSum;
    finalDueDate.value = null;
    reminderBeforeDueDate.value = false;
    for (final draft in installmentDrafts) {
      draft.dispose();
    }
    installmentDrafts.clear();
    selectedLoanId.value = null;
    loadLiabilities();
    resetQuickEntry();
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final loan = mergedItems
        .firstWhereOrNull((b) => b.liability.id == selectedLoanId.value)
        ?.liability;
    if (loan == null) {
      isSubmitting.value = false;
      return;
    }

    if (loan.principalAmount > 0) {
      final params = RecordLoanPaymentParams(
        loanId: loan.id,
        walletId: selectedWalletId.value ?? '',
        amount: int.tryParse(amountStr.value) ?? 0,
        note: composeNote(),
        date: date.value,
      );

      final result = await getIt<RecordLiabilityPaymentUseCase>().call(params);
      isSubmitting.value = false;

      result.when(
        (updatedLoan) async {
          final savedAmount = TransactionFormHelpers.formatAmount(
            amountStr.value,
          );
          CcSnackBarHelper.showSuccessSnackBar(
            context: context,
            message: el.tr(
              CcLocaleKeys.transaction_liability_payment_saved,
              namedArgs: {'amount': savedAmount},
            ),
          );
          resetForm();
          await refreshParent();

          if (Get.isRegistered<GuidelineController>()) {
            Get.find<GuidelineController>().completeTask('liability');
          }
        },
        (error) => CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(error.message),
        ),
      );
      return;
    }

    final category = selectedCategory.value!;
    final categoryLabel = el.tr(category.nameKey);
    final isInstallment =
        repaymentMethod.value == LiabilityRepaymentMethod.installment;

    final params = CreateLoanParams(
      loanId: loan.id,
      direction: direction,
      principalAmount: int.tryParse(amountStr.value) ?? 0,
      categoryId: category.id,
      categoryLabel: categoryLabel,
      categoryIconCode: category.iconCode,
      categoryIconFamily: category.iconFamily,
      walletId: selectedWalletId.value ?? '',
      repaymentMethod: repaymentMethod.value,
      installments: isInstallment
          ? installmentDrafts
                .map(
                  (d) => LiabilityInstallmentEntity(
                    dueDate: d.dueDate.value,
                    amount: d.amount.value,
                  ),
                )
                .toList()
          : null,
      finalDueDate: isInstallment ? null : finalDueDate.value,
      note: composeNote(),
      date: date.value,
      reminderBeforeDueDate: reminderBeforeDueDate.value,
    );

    final result = await getIt<CreateLiabilityUseCase>().call(params);
    isSubmitting.value = false;

    result.when(
      (updatedLoan) async {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_liability_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        getIt<ScheduleLiabilityRemindersUseCase>().call(updatedLoan);
        resetForm();
        await refreshParent();

        if (Get.isRegistered<GuidelineController>()) {
          Get.find<GuidelineController>().completeTask('liability');
        }
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
