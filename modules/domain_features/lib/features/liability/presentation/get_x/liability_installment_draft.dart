import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One editable row of an installment schedule being built in the liability
/// creation form. Presentation-only — converted to [LiabilityInstallmentEntity]
/// at submit time.
class LiabilityInstallmentDraft {
  final Rx<DateTime> dueDate;
  final TextEditingController amountController = TextEditingController();
  final RxInt amount = 0.obs;

  LiabilityInstallmentDraft(DateTime initialDueDate)
    : dueDate = initialDueDate.obs;

  void setAmount(String value) {
    amount.value = int.tryParse(value) ?? 0;
  }

  void dispose() {
    amountController.dispose();
  }
}
