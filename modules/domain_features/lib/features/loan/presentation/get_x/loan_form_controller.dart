import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../transaction/presentation/get_x/quick_entry_mixin.dart';
import '../../../transaction/presentation/get_x/transaction_form_controller.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/usecases/create_loan_usecase.dart';
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

/// Creates a new loan (Đi vay/Cho vay). Repaying/collecting an existing loan
/// is handled on the Loan Detail screen (see `LoanDetailController`), not here.
@injectable
class LoanFormController extends TransactionFormController
    with QuickEntryMixin {
  @override
  String get quickEntryCategoryType => CategoryType.debtLoan;

  /// Restricts quick-entry's category match to whichever direction group is
  /// currently selected — same filter the category picker itself applies
  /// (see `loan_form.dart`), so a suggestion never resolves to a category
  /// the picker wouldn't even show right now.
  @override
  List<String> get quickEntryCategoryGroupIds => [
    direction.value == LoanDirection.borrow
        ? CategorySeed.debtLoanBorrowGroupId
        : CategorySeed.debtLoanLendGroupId,
  ];

  /// Set right before [categoryKey] is bumped by
  /// [QuickEntryMixin.applyQuickEntryCategory], so the remounted
  /// `CategorySelectionSection` resolves and reports back the real
  /// [CategoryEntity] for this id.
  @override
  final Rx<String?> pendingPrefillCategoryId = Rx<String?>(null);

  final RxString direction = LoanDirection.borrow.obs;
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  @override
  final RxInt categoryKey = 0.obs;
  final RxString repaymentMethod = LoanRepaymentMethod.lumpSum.obs;
  final Rx<DateTime?> finalDueDate = Rx<DateTime?>(null);
  final RxList<LoanInstallmentDraft> installmentDrafts =
      <LoanInstallmentDraft>[].obs;
  final RxBool reminderBeforeDueDate = false.obs;

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
  void onInit() {
    super.onInit();
    _loadVipStatus();
    initQuickEntry();
  }

  Future<void> _loadVipStatus() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    if (!settings.isVip) return;
    isVip.value = true;
  }

  @override
  bool get canSubmit {
    if (amountStr.value == '0' || amountStr.value.isEmpty) return false;
    if (selectedWalletId.value == null) return false;
    if (selectedCategory.value == null) return false;
    if (repaymentMethod.value == LoanRepaymentMethod.installment) {
      if (installmentDrafts.isEmpty) return false;
      // Total installments must equal principal amount
      if (installmentsTotal != principalAmount) return false;
      return installmentDrafts.every((d) => d.amount.value > 0);
    }
    return finalDueDate.value != null;
  }

  @override
  void onClose() {
    for (final draft in installmentDrafts) {
      draft.dispose();
    }
    disposeQuickEntry();
    super.onClose();
  }

  void setDirection(String value) {
    if (direction.value == value) return;
    direction.value = value;
    selectedCategory.value = null;
    // The other direction's category group no longer applies — a stale
    // quick-entry prefill from it must not linger into the new group.
    pendingPrefillCategoryId.value = null;
    categoryKey.value++;
    // quickEntryCategoryGroupIds now points at the new direction's group —
    // reload the label-lookup cache so quickEntryResultLabel doesn't keep
    // searching the old (now-stale) group for a category it can't find.
    refreshQuickEntryCategories();
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    // Manual selection clears any pending prefill from AI suggestions so it
    // doesn't clobber the user's choice on the next rebuild.
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
    resetQuickEntry();
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final category = selectedCategory.value!;
    final categoryLabel = el.tr(category.nameKey);
    final isInstallment =
        repaymentMethod.value == LoanRepaymentMethod.installment;

    final params = CreateLoanParams(
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
      (loan) {
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
        getIt<ScheduleLoanRemindersUseCase>().call(loan);
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
