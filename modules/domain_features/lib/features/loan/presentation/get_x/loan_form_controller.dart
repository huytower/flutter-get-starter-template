import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../transaction/presentation/get_x/transaction_form_controller.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';
import '../../domain/entities/loan_balance_entity.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/usecases/create_loan_usecase.dart';
import '../../domain/usecases/get_loan_balances_usecase.dart';
import '../../domain/usecases/record_loan_payment_usecase.dart';
import '../../domain/usecases/schedule_loan_reminders_usecase.dart';

/// One editable row of an installment schedule being built in the loan
/// creation form. Presentation-only — converted to [LoanInstallmentEntity]
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

/// Consolidated Loan/Debt form: handles recording transactions against
/// existing loans (Repay/Collect) or completing a new loan's details.
/// Consolidated with the Dashboard's Liability section quantity.
@injectable
class LoanFormController extends TransactionFormController {
  final RxString direction = LoanDirection.borrow.obs;
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final RxInt categoryKey = 0.obs;
  final RxString repaymentMethod = LoanRepaymentMethod.lumpSum.obs;
  final Rx<DateTime?> finalDueDate = Rx<DateTime?>(null);
  final RxList<LoanInstallmentDraft> installmentDrafts =
      <LoanInstallmentDraft>[].obs;
  final RxBool reminderBeforeDueDate = false.obs;

  /// Existing loans loaded from the repository, matching the Dashboard's
  /// Liability section.
  final RxList<LoanBalanceEntity> loanBalances = <LoanBalanceEntity>[].obs;
  final RxList<LoanBalanceEntity> mergedItems = <LoanBalanceEntity>[].obs;
  final RxBool isLoadingMerged = true.obs;
  final RxnString selectedLoanId = RxnString();

  /// Index of the installment currently being edited via the money keypad.
  /// Null when editing the main loan amount.
  final RxnInt editingInstallmentIndex = RxnInt();

  /// Free-tier gate: non-VIP users can only name a loan/lend after its
  /// category (e.g. "Vay ngân hàng/TCTD") — only VIP unlocks typing a
  /// custom counterparty/loan name. Defaults to `false` until
  /// [_loadVipStatus] resolves.
  final RxBool isVip = false.obs;

  int get principalAmount => int.tryParse(amountStr.value) ?? 0;

  int get installmentsTotal =>
      installmentDrafts.fold(0, (sum, d) => sum + d.amount.value);

  bool get canAddInstallment =>
      principalAmount > 0 && installmentsTotal < principalAmount;

  @override
  bool get canSubmit {
    if (selectedLoanId.value == null) return false;
    if (amountStr.value == '0' || amountStr.value.isEmpty) return false;
    if (selectedWalletId.value == null) return false;

    final loan = mergedItems
        .firstWhereOrNull((b) => b.loan.id == selectedLoanId.value)
        ?.loan;
    if (loan == null) return false;

    // If it's a new loan (0 principal), we need more details
    if (loan.principalAmount == 0) {
      if (repaymentMethod.value == LoanRepaymentMethod.installment) {
        if (installmentDrafts.isEmpty) return false;
        if (installmentsTotal != principalAmount) return false;
        return installmentDrafts.every((d) => d.amount.value > 0);
      }
      return finalDueDate.value != null;
    }

    return true;
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoadingMerged.value = true;
    await _loadVipStatus();
    await _recomputeMergedItems();
    isLoadingMerged.value = false;
  }

  Future<void> _recomputeMergedItems() async {
    final result = await getIt<GetLoanBalancesUseCase>().call();
    result.when((balances) {
      loanBalances.assignAll(balances);
      final filtered = balances.where((b) {
        return direction.value == LoanDirection.borrow
            ? b.loan.isBorrow
            : b.loan.isLend;
      }).toList();

      // Sort by recency to match Dashboard logic
      filtered.sort((a, b) => b.loan.updatedAt.compareTo(a.loan.updatedAt));

      mergedItems.assignAll(filtered);

      // Auto-select first if nothing selected
      if (selectedLoanId.value == null && mergedItems.isNotEmpty) {
        selectLoan(mergedItems.first);
      }
    }, (_) {});
  }

  void selectLoan(LoanBalanceEntity balance) {
    selectedLoanId.value = balance.loan.id;
    // Pre-fill category from loan for consistent submit logic
    _loadCategoryForLoan(balance.loan.categoryId);

    // If it's an existing loan with actual principal, we are in "Repay/Collect" mode
    if (balance.loan.principalAmount > 0) {
      // Clear creation-specific fields
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
    isVip.value = settings.isVip || CcFeatureFlags.isForceFullAccessEnabled;
  }

  @override
  void onClose() {
    for (final draft in installmentDrafts) {
      draft.dispose();
    }
    super.onClose();
  }

  void setDirection(String value) {
    if (direction.value == value) return;
    direction.value = value;
    selectedCategory.value = null;
    categoryKey.value++;
    selectedLoanId.value = null;
    _recomputeMergedItems();
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
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
      // For the first installment, default to 1 month after the loan start date
      lastDate = date.value;
    }

    // Logic: if the first installment has an amount, use it as default for new rows
    // but cap it by the remaining balance
    final remaining = principalAmount - installmentsTotal;
    var defaultAmount = installmentDrafts.isNotEmpty
        ? installmentDrafts.first.amount.value
        : 0;
    if (defaultAmount > remaining) defaultAmount = remaining;

    // Use the same day in the next month (e.g. 12/09 -> 12/10)
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
    repaymentMethod.value = LoanRepaymentMethod.lumpSum;
    finalDueDate.value = null;
    reminderBeforeDueDate.value = false;
    for (final draft in installmentDrafts) {
      draft.dispose();
    }
    installmentDrafts.clear();
    selectedLoanId.value = null;
    _recomputeMergedItems();
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final loan = mergedItems
        .firstWhereOrNull((b) => b.loan.id == selectedLoanId.value)
        ?.loan;
    if (loan == null) {
      isSubmitting.value = false;
      return;
    }

    // Existing loan with principal: Record payment
    if (loan.principalAmount > 0) {
      final params = RecordLoanPaymentParams(
        loanId: loan.id,
        walletId: selectedWalletId.value ?? '',
        amount: int.tryParse(amountStr.value) ?? 0,
        note: composeNote(),
        date: date.value,
      );

      final result = await getIt<RecordLoanPaymentUseCase>().call(params);
      isSubmitting.value = false;

      result.when(
        (updatedLoan) {
          final savedAmount = TransactionFormHelpers.formatAmount(
            amountStr.value,
          );
          CcSnackBarHelper.showSuccessSnackBar(
            context: context,
            message: el.tr(
              CcLocaleKeys.transaction_loan_payment_saved,
              namedArgs: {'amount': savedAmount},
            ),
          );
          resetForm();
          refreshParent();

          // Update Dashboard
          if (Get.isRegistered<WalletController>()) {
            Get.find<WalletController>().loadWallets();
          }
        },
        (error) => CcSnackBarHelper.showErrorSnackBar(
          context: context,
          message: el.tr(error.message),
        ),
      );
      return;
    }

    // New loan (0 principal placeholder): Complete details
    final category = selectedCategory.value!;
    final categoryLabel = el.tr(category.nameKey);
    final isInstallment =
        repaymentMethod.value == LoanRepaymentMethod.installment;

    final params = CreateLoanParams(
      loanId: loan.id,
      direction: direction.value,
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
                  (d) => LoanInstallmentEntity(
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

    final result = await getIt<CreateLoanUseCase>().call(params);
    isSubmitting.value = false;

    result.when(
      (updatedLoan) {
        final savedAmount = TransactionFormHelpers.formatAmount(
          amountStr.value,
        );
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_loan_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        getIt<ScheduleLoanRemindersUseCase>().call(updatedLoan);
        resetForm();
        refreshParent();
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(error.message),
      ),
    );
  }
}
