import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/getx/cc_get_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import 'expense_form_controller.dart';
import 'income_form_controller.dart';

@injectable
class EditTransactionSheetController extends CcGetController {
  static const editTag = 'edit_transaction';

  late final TransactionEntity transaction;
  late final VoidCallback _onCloseSheet;

  final RxBool _isExpense = false.obs;
  final RxBool _isIncome = false.obs;

  bool get isExpense => _isExpense.value;
  bool get isIncome => _isIncome.value;
  bool get isInvestment => transaction.isInvestmentActivity;
  bool get isDebt => transaction.isDebtActivity;

  Color accentColor(BuildContext context) {
    if (isExpense) return context.ccColorScheme.error;
    if (isIncome) return PrjColors.success;
    if (isInvestment) return context.ccColorScheme.investment;
    if (isDebt) return context.ccColorScheme.liability;
    return context.ccColorScheme.primary;
  }

  void init(TransactionEntity tx, VoidCallback onCloseSheet) {
    transaction = tx;
    _onCloseSheet = onCloseSheet;
    _isExpense.value = tx.type == TransactionType.expense;
    _isIncome.value = tx.type == TransactionType.income;

    if (isExpense) {
      final controller = Get.put(getIt<ExpenseFormController>(), tag: editTag);
      controller.onEditSaved = _onCloseSheet;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadForEdit(transaction);
      });
    } else if (isIncome) {
      final controller = Get.put(getIt<IncomeFormController>(), tag: editTag);
      controller.onEditSaved = _onCloseSheet;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadForEdit(transaction);
      });
    }
  }

  @override
  void onClose() {
    if (isExpense) {
      Get.delete<ExpenseFormController>(tag: editTag);
    } else if (isIncome) {
      Get.delete<IncomeFormController>(tag: editTag);
    }
    super.onClose();
  }
}
