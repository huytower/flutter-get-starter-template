import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/budget_name_helper.dart';
import '../../../liability/presentation/get_x/lend_form_controller.dart';
import '../../../liability/presentation/get_x/liability_form_controller.dart';
import '../../../liability/presentation/widgets/lend_asset_selector.dart';
import '../../../liability/presentation/widgets/liability_asset_selector.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/domain/usecases/update_transaction_usecase.dart';
import '../../../transaction/presentation/get_x/investment_form_controller.dart';
import '../../../transaction/presentation/widgets/category_selection_section.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/investment_asset_selector.dart';
import '../../../transaction/presentation/widgets/transaction_form_container.dart';
import '../../../transaction/presentation/widgets/transaction_submit_button.dart';

void _quickEditDebug(String message) {
  '[QUICK_EDIT_DEBUG] $message'.Log('QuickEditTransactionSheet');
}

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

  InvestmentFormController? _investmentController;
  LiabilityFormController? _liabilityController;
  LendFormController? _lendController;

  bool get _isInvestment => widget.transaction.isInvestmentActivity;
  bool get _isDebt => widget.transaction.isDebtActivity;
  bool get _isLend =>
      widget.transaction.type == TransactionType.debtLend ||
      widget.transaction.type == TransactionType.debtCollect;
  bool get _isBorrow =>
      widget.transaction.type == TransactionType.debtBorrow ||
      widget.transaction.type == TransactionType.debtRepay;

  Color get _accentColor {
    if (_isInvestment) return PrjColors.investment;
    if (_isDebt) return PrjColors.liability;
    return context.ccColorScheme.primary;
  }

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _selectedDate = widget.transaction.date;
    _noteController.text = widget.transaction.note ?? '';

    _quickEditDebug(
      'initState: id=${widget.transaction.id}, type=${widget.transaction.type}, category=${widget.transaction.category}, amount=${widget.transaction.amount}, isInvestment=$_isInvestment, isBorrow=$_isBorrow, isLend=$_isLend',
    );

    if (_isInvestment) {
      _investmentController = Get.put(
        getIt<InvestmentFormController>(),
        tag: 'quick_edit_${widget.transaction.id}',
      );
      if (widget.transaction.investmentWalletId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _investmentController != null) {
            _investmentController!.selectedInvestmentWalletId.value =
                widget.transaction.investmentWalletId;
          }
        });
      }
    } else if (_isBorrow) {
      _liabilityController = Get.put(
        getIt<LiabilityFormController>(),
        tag: 'quick_edit_${widget.transaction.id}',
      );
      if (widget.transaction.liabilityId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _liabilityController != null) {
            _liabilityController!.selectedLiabilityId.value =
                widget.transaction.liabilityId;
          }
        });
      }
    } else if (_isLend) {
      _lendController = Get.put(
        getIt<LendFormController>(),
        tag: 'quick_edit_${widget.transaction.id}',
      );
      if (widget.transaction.liabilityId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _lendController != null) {
            _lendController!.selectedLiabilityId.value =
                widget.transaction.liabilityId;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    final tag = 'quick_edit_${widget.transaction.id}';
    if (_investmentController != null) {
      Get.delete<InvestmentFormController>(tag: tag);
    }
    if (_liabilityController != null) {
      Get.delete<LiabilityFormController>(tag: tag);
    }
    if (_lendController != null) {
      Get.delete<LendFormController>(tag: tag);
    }
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
        return CategoryType.liability;
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

    final String categoryId;
    final String categoryLabel;
    final int? categoryIconCode;
    final String? categoryIconFamily;

    if (_isInvestment && _investmentController != null) {
      final selectedCat = _investmentController!.selectedCategory.value;
      categoryId = selectedCat?.id ?? widget.transaction.categoryId;
      categoryLabel = selectedCat != null
          ? el.tr(selectedCat.nameKey)
          : widget.transaction.category;
      categoryIconCode =
          selectedCat?.iconCode ?? widget.transaction.categoryIconCode;
      categoryIconFamily =
          selectedCat?.iconFamily ?? widget.transaction.categoryIconFamily;
      _quickEditDebug(
        '_save investment: categoryId=$categoryId, categoryLabel=$categoryLabel',
      );
    } else if (_isBorrow && _liabilityController != null) {
      final selectedLiabilityId =
          _liabilityController!.selectedLiabilityId.value;
      final balance = _liabilityController!.mergedItems.firstWhereOrNull(
        (b) => b.liability.id == selectedLiabilityId,
      );
      categoryId =
          balance?.liability.categoryId ?? widget.transaction.categoryId;
      categoryLabel = balance != null
          ? BudgetNameHelper.getDisplayName(
              name: balance.liability.categoryLabel,
              categoryNameKey: balance.liability.categoryNameKey,
            )
          : widget.transaction.category;
      categoryIconCode =
          balance?.liability.categoryIconCode ??
          widget.transaction.categoryIconCode;
      categoryIconFamily =
          balance?.liability.categoryIconFamily ??
          widget.transaction.categoryIconFamily;
      _quickEditDebug(
        '_save borrow: categoryId=$categoryId, categoryLabel=$categoryLabel, selectedLiabilityId=$selectedLiabilityId',
      );
    } else if (_isLend && _lendController != null) {
      final selectedLiabilityId = _lendController!.selectedLiabilityId.value;
      final balance = _lendController!.mergedItems.firstWhereOrNull(
        (b) => b.liability.id == selectedLiabilityId,
      );
      categoryId =
          balance?.liability.categoryId ?? widget.transaction.categoryId;
      categoryLabel = balance != null
          ? BudgetNameHelper.getDisplayName(
              name: balance.liability.categoryLabel,
              categoryNameKey: balance.liability.categoryNameKey,
            )
          : widget.transaction.category;
      categoryIconCode =
          balance?.liability.categoryIconCode ??
          widget.transaction.categoryIconCode;
      categoryIconFamily =
          balance?.liability.categoryIconFamily ??
          widget.transaction.categoryIconFamily;
      _quickEditDebug(
        '_save lend: categoryId=$categoryId, categoryLabel=$categoryLabel, selectedLiabilityId=$selectedLiabilityId',
      );
    } else {
      categoryId = _selectedCategory?.id ?? widget.transaction.categoryId;
      categoryLabel = _selectedCategory != null
          ? el.tr(_selectedCategory!.nameKey)
          : widget.transaction.category;
      categoryIconCode =
          _selectedCategory?.iconCode ?? widget.transaction.categoryIconCode;
      categoryIconFamily =
          _selectedCategory?.iconFamily ??
          widget.transaction.categoryIconFamily;
      _quickEditDebug(
        '_save general: categoryId=$categoryId, categoryLabel=$categoryLabel',
      );
    }

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
                    _buildCategorySelectionSection(),
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
                      activeColor: _accentColor,
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

  Widget _buildCategorySelectionSection() {
    if (_isInvestment && _investmentController != null) {
      _quickEditDebug(
        'buildCategorySelectionSection: rendering InvestmentAssetSelector with mergedItems count=${_investmentController!.mergedItems.length}',
      );
      return InvestmentAssetSelector(
        controller: _investmentController!,
        activeColor: _accentColor,
      );
    }

    if (_isBorrow && _liabilityController != null) {
      _quickEditDebug(
        'buildCategorySelectionSection: rendering LiabilityAssetSelector with mergedItems count=${_liabilityController!.mergedItems.length}',
      );
      return LiabilityAssetSelector(
        controller: _liabilityController!,
        activeColor: _accentColor,
      );
    }

    if (_isLend && _lendController != null) {
      _quickEditDebug(
        'buildCategorySelectionSection: rendering LendAssetSelector with mergedItems count=${_lendController!.mergedItems.length}',
      );
      return LendAssetSelector(
        controller: _lendController!,
        activeColor: _accentColor,
      );
    }

    return CategorySelectionSection(
      type: _categoryType!,
      activeColor: _accentColor,
      autoSelectFirst: false,
      initialSelectedCategoryId: widget.transaction.categoryId,
      onCategorySelected: (category) {
        if (mounted) {
          setState(() => _selectedCategory = category);
        }
      },
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
      activeColor: _accentColor,
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
    );
  }
}
