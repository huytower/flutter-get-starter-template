import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/usecases/update_transaction_usecase.dart';
import '../../../transaction/presentation/widgets/category_selection_section.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/transaction_form_container.dart';
import '../../../transaction/presentation/widgets/transaction_submit_button.dart';

class QuickEditTransactionSheet extends StatefulWidget {
  const QuickEditTransactionSheet({super.key, required this.transaction});

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
      builder: (_) => QuickEditTransactionSheet(transaction: transaction),
    );
  }

  @override
  State<QuickEditTransactionSheet> createState() =>
      _QuickEditTransactionSheetState();
}

class _QuickEditTransactionSheetState extends State<QuickEditTransactionSheet> {
  bool _isSubmitting = false;
  final TextEditingController _noteController = TextEditingController();
  late final TextEditingController _amountController;
  late DateTime _selectedDate;
  CategoryEntity? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _selectedDate = widget.transaction.date;
    _noteController.text = widget.transaction.note ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? get _categoryType {
    switch (widget.transaction.type) {
      case TransactionType.expense:
        return CategoryType.expense;
      case TransactionType.income:
        return CategoryType.income;
      case TransactionType.debtBorrow:
      case TransactionType.debtLend:
      case TransactionType.debtRepay:
      case TransactionType.debtCollect:
        return CategoryType.debtLoan;
      case TransactionType.investmentOut:
      case TransactionType.investmentIn:
      case TransactionType.investmentReturn:
        return CategoryType.investment;
      default:
        return CategoryType.expense;
    }
  }

  Future<void> _save() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final updateUseCase = getIt<UpdateTransactionUseCase>();
    final newAmount = int.tryParse(_amountController.text.trim()) ?? 0;
    final noteText = _noteController.text.trim();

    final categoryId = _selectedCategory?.id ?? widget.transaction.categoryId;
    final categoryLabel = _selectedCategory != null
        ? el.tr(_selectedCategory!.nameKey)
        : widget.transaction.category;
    final categoryIconCode =
        _selectedCategory?.iconCode ?? widget.transaction.categoryIconCode;
    final categoryIconFamily =
        _selectedCategory?.iconFamily ?? widget.transaction.categoryIconFamily;

    final result = await updateUseCase.call(
      UpdateTransactionParams(
        original: widget.transaction,
        amount: newAmount,
        categoryId: categoryId,
        categoryLabel: categoryLabel,
        categoryIconCode: categoryIconCode,
        categoryIconFamily: categoryIconFamily,
        walletId: widget.transaction.walletId,
        note: noteText.isEmpty ? null : noteText,
        date: _selectedDate,
      ),
    );

    if (!mounted) return;

    if (result.isSuccess()) {
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: el.tr(CcLocaleKeys.common_save),
      );
      Navigator.of(context).pop();
    } else {
      CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message:
            result.tryGetError()?.message ??
            el.tr(CcLocaleKeys.app_error_general),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategorySelectionSection(
                      type: _categoryType!,
                      activeColor: context.ccColorScheme.primary,
                      autoSelectFirst: false,
                      initialSelectedCategoryId: widget.transaction.categoryId,
                      onCategorySelected: (category) {
                        if (mounted) {
                          setState(() => _selectedCategory = category);
                        }
                      },
                    ),
                    const CcSpaceSM(),
                    _buildAmountSection(context),
                    const CcSpaceSM(),
                    TransactionFormContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [_buildDateAndNoteSection(context)],
                      ),
                    ),
                    const CcSpaceSM(),
                    TransactionSubmitButton(
                      text: el.tr(CcLocaleKeys.common_save),
                      isSubmitting: _isSubmitting,
                      isEnabled: true,
                      onTap: _save,
                      activeColor: context.ccColorScheme.primary,
                    ),
                    const CcSpaceXS(),
                  ],
                ),
              ),
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

  Widget _buildAmountSection(BuildContext context) {
    return CcAmountInputSection(
      label: el.tr(CcLocaleKeys.transaction_amount),
      amountStr: _amountController.text,
      quickAmounts: const [
        10000,
        20000,
        50000,
        100000,
        200000,
        500000,
        1000000,
      ],
      isKeypadVisible: false,
      activeColor: context.ccColorScheme.primary,
      onTap: () {},
      onQuickAmountSelected: (amount) {
        _amountController.text = amount.toString();
      },
      onClear: () => _amountController.text = '0',
    );
  }

  Widget _buildDateAndNoteSection(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcNoteInputField(
      controller: _noteController,
      hintText: el.tr(CcLocaleKeys.transaction_note_hint),
      maxLines: 2,
      color: scheme.surfaceVariant.withAlpha(80),
      borderColor: scheme.outlineVariant.withAlpha(10),
      height: context.respDim(45),
      margin: EdgeInsets.zero,
      showCopy: false,
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          left: context.respPadding(CcPaddingParams.SPACE_SM),
          right: context.respPadding(CcPaddingParams.SPACE_XS),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CcText(
              el.tr(CcLocaleKeys.transaction_note),
              textStyle: context.ccTextTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant.withAlpha(70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
