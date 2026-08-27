import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../transaction/presentation/get_x/quick_entry_mixin.dart';
import '../../../transaction/presentation/get_x/transaction_form_controller.dart';
import '../../domain/entities/liability_balance_entity.dart';
import 'liability_form_controller.dart';

enum LiabilityFormAction { increase, decrease }

abstract class LiabilityBaseFormController extends TransactionFormController
    with QuickEntryMixin {
  RxList<LiabilityBalanceEntity> get mergedItems;
  RxBool get isLoadingMerged;
  RxnString get selectedLoanId;
  RxList<LoanInstallmentDraft> get installmentDrafts;
  RxnInt get editingInstallmentIndex;
  RxBool get reminderBeforeDueDate;
  RxString get repaymentMethod;
  Rx<DateTime?> get finalDueDate;
  int get principalAmount;
  int get installmentsTotal;
  bool get canAddInstallment;
  String get direction;

  Rx<LiabilityFormAction> get action;
  void setAction(LiabilityFormAction value);

  void selectLoan(LiabilityBalanceEntity balance);
  void setRepaymentMethod(String value);
  void setReminderBeforeDueDate(bool value);
  Future<void> pickFinalDueDate(BuildContext context);
  Future<void> pickInstallmentDueDate(BuildContext context, int index);
  void addInstallmentPeriod();
  void removeInstallmentPeriod(int index);
  void showKeypadForInstallment(BuildContext context, int index);
}
