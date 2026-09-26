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
class EditTransactionSheet extends GetView<EditTransactionSheetController> {
  const EditTransactionSheet({super.key});

  static Future<void> show(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    final controller = Get.put(getIt<EditTransactionSheetController>());
    controller.init(transaction, () {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const EditTransactionSheet(),
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (Get.isRegistered<EditTransactionSheetController>()) {
          Get.delete<EditTransactionSheetController>();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpense = controller.isExpense;
      final isIncome = controller.isIncome;

      // Only income/expense transactions are editable here; if this is a
      // transfer or investment/liability entry, dismiss immediately.
      if (!isIncome && !isExpense) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && Navigator.of(context).canPop()) {
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
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, accentColor),
              Flexible(
                fit: FlexFit.loose,
                child: isExpense
                    ? const ExpenseForm(
                        tag: EditTransactionSheetController.editTag,
                      )
                    : const IncomeForm(
                        tag: EditTransactionSheetController.editTag,
                      ),
              ),
            ],
          ),
        ),
      );
    });
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
