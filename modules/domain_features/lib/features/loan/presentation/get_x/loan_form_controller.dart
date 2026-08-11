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

  LoanInstallmentDraft(DateTime initialDueDate)
    : dueDate = initialDueDate.obs;

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
class LoanFormController extends TransactionFormController {
  final RxString direction = LoanDirection.borrow.obs;
  final Rx<CategoryEntity?> selectedCategory = Rx<CategoryEntity?>(null);
  final RxInt categoryKey = 0.obs;
  final TextEditingController counterpartyController = TextEditingController();
  final RxString counterpartyName = ''.obs;
  final RxString repaymentMethod = LoanRepaymentMethod.lumpSum.obs;
  final Rx<DateTime?> finalDueDate = Rx<DateTime?>(null);
  final RxList<LoanInstallmentDraft> installmentDrafts =
      <LoanInstallmentDraft>[].obs;
  final RxBool reminderBeforeDueDate = false.obs;

  /// Free-tier gate: non-VIP users can only name a loan/lend after its
  /// category (e.g. "Vay ngân hàng/TCTD") — only VIP unlocks typing a
  /// custom counterparty/loan name. Defaults to `false` until
  /// [_loadVipStatus] resolves.
  final RxBool isVip = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVipStatus();
  }

  Future<void> _loadVipStatus() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    if (!settings.isVip) return;
    isVip.value = true;
    counterpartyName.value = '';
    counterpartyController.clear();
  }

  @override
  bool get canSubmit {
    if (amountStr.value == '0' || amountStr.value.isEmpty) return false;
    if (selectedWalletId.value == null) return false;
    if (selectedCategory.value == null) return false;
    if (counterpartyName.value.trim().isEmpty) return false;
    if (repaymentMethod.value == LoanRepaymentMethod.installment) {
      if (installmentDrafts.isEmpty) return false;
      return installmentDrafts.every((d) => d.amount.value > 0);
    }
    return finalDueDate.value != null;
  }

  @override
  void onClose() {
    counterpartyController.dispose();
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
  }

  void setCategory(CategoryEntity category) {
    selectedCategory.value = category;
    // Free tier: the loan/lend name is fixed to the category's own label —
    // no custom counterparty name until VIP.
    if (!isVip.value) {
      counterpartyName.value = el.tr(category.nameKey);
    }
  }

  void setCounterparty(String value) {
    counterpartyName.value = value;
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
    return showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: DateTime(now.year + 10),
    );
  }

  void addInstallmentPeriod() {
    final lastDate = installmentDrafts.isNotEmpty
        ? installmentDrafts.last.dueDate.value
        : DateTime.now();
    installmentDrafts.add(
      LoanInstallmentDraft(lastDate.add(const Duration(days: 30))),
    );
  }

  void removeInstallmentPeriod(int index) {
    installmentDrafts.removeAt(index).dispose();
  }

  @override
  void onReset() {
    selectedCategory.value = null;
    categoryKey.value++;
    counterpartyController.clear();
    counterpartyName.value = '';
    repaymentMethod.value = LoanRepaymentMethod.lumpSum;
    finalDueDate.value = null;
    reminderBeforeDueDate.value = false;
    for (final draft in installmentDrafts) {
      draft.dispose();
    }
    installmentDrafts.clear();
  }

  @override
  Future<void> submitForm(BuildContext context) async {
    if (isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;

    final category = selectedCategory.value!;
    final categoryLabel = el.tr(category.nameKey);
    final isInstallment = repaymentMethod.value == LoanRepaymentMethod.installment;

    final params = CreateLoanParams(
      direction: direction.value,
      counterpartyName: counterpartyName.value.trim(),
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
