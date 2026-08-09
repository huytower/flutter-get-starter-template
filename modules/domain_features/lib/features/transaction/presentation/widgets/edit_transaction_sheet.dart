import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../domain/entities/transaction_entity.dart';
import '../get_x/expense_form_controller.dart';
import '../get_x/income_form_controller.dart';
import 'expense_form.dart';
import 'income_form.dart';

/// Bottom sheet for correcting a previously recorded income/expense
/// transaction — reuses [ExpenseForm]/[IncomeForm] as-is in edit mode via a
/// tagged GetX instance, so the entry tab's own in-progress draft is never
/// touched.
class EditTransactionSheet extends StatefulWidget {
  const EditTransactionSheet({super.key, required this.transaction});

  final TransactionEntity transaction;

  static const _tag = 'edit_transaction';

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
  State<EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<EditTransactionSheet> {
  bool get _isExpense => widget.transaction.type == TransactionType.expense;

  @override
  void initState() {
    super.initState();
    if (_isExpense) {
      final controller = Get.put(
        getIt<ExpenseFormController>(),
        tag: EditTransactionSheet._tag,
      );
      controller.onEditSaved = _close;
      controller.loadForEdit(widget.transaction);
    } else {
      final controller = Get.put(
        getIt<IncomeFormController>(),
        tag: EditTransactionSheet._tag,
      );
      controller.onEditSaved = _close;
      controller.loadForEdit(widget.transaction);
    }
  }

  @override
  void dispose() {
    if (_isExpense) {
      Get.delete<ExpenseFormController>(tag: EditTransactionSheet._tag);
    } else {
      Get.delete<IncomeFormController>(tag: EditTransactionSheet._tag);
    }
    super.dispose();
  }

  void _close() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isExpense
                  ? const ExpenseForm(tag: EditTransactionSheet._tag)
                  : const IncomeForm(tag: EditTransactionSheet._tag),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
