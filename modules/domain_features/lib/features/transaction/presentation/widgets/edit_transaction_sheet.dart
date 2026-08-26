import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/transaction/domain/entities/transaction_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
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
  bool get _isIncome => widget.transaction.type == TransactionType.income;
  bool get _isInvestment => widget.transaction.isInvestmentActivity;
  bool get _isDebt => widget.transaction.isDebtActivity;

  Color get _accentColor {
    if (_isExpense) return context.ccColorScheme.error;
    if (_isIncome) return PrjColors.success;
    if (_isInvestment) return PrjColors.investment;
    if (_isDebt) return PrjColors.debtLoan;
    return context.ccColorScheme.primary;
  }

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
    } else if (_isIncome) {
      final controller = Get.put(
        getIt<IncomeFormController>(),
        tag: EditTransactionSheet._tag,
      );
      controller.onEditSaved = _close;
      controller.loadForEdit(widget.transaction);
    }
    // Investment and debt transactions are not yet editable via this sheet
    // When implemented, they will use the appropriate accent colors:
    // - Investment: PrjColors.investment
    // - Debt/Liability: PrjColors.debtLoan
  }

  @override
  void dispose() {
    if (_isExpense) {
      Get.delete<ExpenseFormController>(tag: EditTransactionSheet._tag);
    } else if (_isIncome) {
      Get.delete<IncomeFormController>(tag: EditTransactionSheet._tag);
    }
    super.dispose();
  }

  void _close() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Only show edit form for income and expense transactions
    if (!_isIncome && !_isExpense) {
      // Investment and debt transactions are not yet editable via this sheet
      // When implemented, they will use accent colors:
      // - Investment: PrjColors.investment
      // - Debt/Liability: PrjColors.debtLoan
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              context.respPadding(CcPaddingParams.PAGE_MD),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, _accentColor),
            _isExpense
                ? const ExpenseForm(tag: EditTransactionSheet._tag)
                : const IncomeForm(tag: EditTransactionSheet._tag),
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
