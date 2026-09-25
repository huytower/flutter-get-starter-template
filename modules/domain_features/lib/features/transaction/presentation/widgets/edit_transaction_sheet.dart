import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../get_x/edit_transaction_sheet_controller.dart';
import 'expense_form.dart';
import 'income_form.dart';

/// Bottom sheet for correcting a previously recorded income/expense
/// transaction — reuses [ExpenseForm]/[IncomeForm] as-is in edit mode via a
/// tagged GetX instance, so the entry tab's own in-progress draft is never
/// touched.
class EditTransactionSheet extends StatelessWidget {
  const EditTransactionSheet({super.key, required this.transaction});

  final TransactionEntity transaction;

  static Future<void> show(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditTransactionSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(getIt<EditTransactionSheetController>());
    controller.init(transaction, () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    final isExpense = controller.isExpense;
    final isIncome = controller.isIncome;

    // Only show edit form for income and expense transactions
    if (!isIncome && !isExpense) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    final accentColor = controller.accentColor(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              context.respPadding(CcPaddingParams.PAGE_MD),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, accentColor),
            isExpense
                ? const ExpenseForm(tag: EditTransactionSheetController.editTag)
                : const IncomeForm(tag: EditTransactionSheetController.editTag),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accentColor) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.SPACE_MD),
        vertical: context.respPadding(CcPaddingParams.SPACE_SM),
      ),
      child: Row(
        children: [
          CcText(
            el.tr(CcLocaleKeys.transaction_edit_title),
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
