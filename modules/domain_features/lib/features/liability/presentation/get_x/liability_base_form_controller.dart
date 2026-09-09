import 'package:cc_sdk/core/extensions/common/cc_logger_extension.dart';
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
  RxnString get selectedLiabilityId;
  RxList<LiabilityInstallmentDraft> get installmentDrafts;
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

  void selectLiability(
    LiabilityBalanceEntity balance, {
    bool resetAmount = true,
    String? amount,
  });
  void setRepaymentMethod(String value);
  void setReminderBeforeDueDate(bool value);
  Future<void> pickFinalDueDate(BuildContext context);
  Future<void> pickInstallmentDueDate(BuildContext context, int index);
  void addInstallmentPeriod();
  void removeInstallmentPeriod(int index);
  void showKeypadForInstallment(BuildContext context, int index);

  @override
  void applyQuickEntryCategory(String categoryId) {
    // 0. Save current parsed amount before selection resets it
    final currentParsedAmount = amountStr.value;

    // 1. Try to find an existing loan/record for this category
    final matchingItems = mergedItems
        .where((b) => b.liability.categoryId == categoryId)
        .toList();

    if (matchingItems.isNotEmpty) {
      // Pick the first one (most recently updated due to loadLiabilities sorting)
      final selected = matchingItems.first;

      '[AI_PARSING] 🎯 Matching existing liability found for category: $categoryId | amount: $currentParsedAmount'
          .Log(runtimeType.toString());

      // Pass the amount explicitly to avoid it being reset to '0' during selection
      selectLiability(
        selected,
        amount: currentParsedAmount != '0' ? currentParsedAmount : null,
      );

      pendingPrefillCategoryId.value = null;
      return;
    }

    // 2. Fallback: let the mixin handle setting pendingPrefillCategoryId
    // and resolving the CategoryEntity.
    super.applyQuickEntryCategory(categoryId);
  }
}
