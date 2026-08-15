import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../transaction/presentation/widgets/category_selection_section.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/cc_form_label.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../../transaction/presentation/widgets/transaction_wallet_selector.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/usecases/create_transaction_template_usecase.dart';
import '../get_x/transaction_template_controller.dart';

/// Bottom sheet to create a new quick-entry template ("Mẫu nhanh").
class AddTransactionTemplateSheet extends StatefulWidget {
  final List<WalletEntity> wallets;

  const AddTransactionTemplateSheet({super.key, required this.wallets});

  @override
  State<AddTransactionTemplateSheet> createState() =>
      _AddTransactionTemplateSheetState();
}

class _AddTransactionTemplateSheetState
    extends State<AddTransactionTemplateSheet> {
  final _controller = Get.isRegistered<TransactionTemplateController>()
      ? Get.find<TransactionTemplateController>()
      : Get.put(getIt<TransactionTemplateController>());
  final _nameController = TextEditingController();
  final _amountFieldKey = GlobalKey();

  String _amountStr = '0';
  bool _showKeypad = false;
  CategoryEntity? _selectedCategory;
  String? _selectedWalletId;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _selectedCategory != null &&
      _selectedWalletId != null &&
      (int.tryParse(_amountStr) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _selectedWalletId = widget.wallets.isNotEmpty
        ? widget.wallets.first.id
        : null;
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    setState(() {
      if (_amountStr == '0') {
        if (key != '0' && key != '000') _amountStr = key;
      } else {
        _amountStr += key;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
  }

  Future<void> _onSave() async {
    final amount = int.tryParse(_amountStr) ?? 0;
    final name = _nameController.text.trim();
    final category = _selectedCategory!;

    final error = await _controller.createTemplate(
      CreateTransactionTemplateParams(
        name: name,
        amount: amount,
        categoryId: category.id,
        categoryLabel: el.tr(category.nameKey),
        categoryIconCode: category.iconCode,
        categoryIconFamily: category.iconFamily,
        walletId: _selectedWalletId!,
      ),
    );

    if (!mounted) return;
    if (error != null) {
      CcSnackBarHelper.showErrorSnackBar(context: context, message: error);
      return;
    }

    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: el.tr(
        CcLocaleKeys.transaction_template_created,
        namedArgs: {'name': name},
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = context.ccColorScheme.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_showKeypad) setState(() => _showKeypad = false);
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: context.respPadding(CcPaddingParams.SPACE_LG),
              right: context.respPadding(CcPaddingParams.SPACE_LG),
              top: context.respPadding(CcPaddingParams.SPACE_LG),
              bottom:
                  (_showKeypad ? 0 : MediaQuery.of(context).viewInsets.bottom) +
                  context.respPadding(CcPaddingParams.SPACE_LG),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  el.tr(CcLocaleKeys.transaction_template_add_title),
                  textStyle: context.ccTextTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const CcSpaceSM(),
                CcTextField(
                  controller: _nameController,
                  hintText: el.tr(CcLocaleKeys.transaction_template_name_hint),
                  maxLines: 1,
                  onTap: () {
                    if (_showKeypad) setState(() => _showKeypad = false);
                  },
                ),
                const CcSpaceSM(),
                CategorySelectionSection(
                  activeColor: accentColor,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                      if (_showKeypad) _showKeypad = false;
                    });
                  },
                ),
                const CcSpaceSM(),
                CcAmountInputSection(
                  label: el.tr(CcLocaleKeys.transaction_amount),
                  amountStr: _amountStr,
                  quickAmounts: MoneyConstants.quickAmounts,
                  isKeypadVisible: _showKeypad,
                  activeColor: accentColor,
                  fieldKey: _amountFieldKey,
                  onTap: () {
                    setState(() => _showKeypad = true);
                    FocusScope.of(context).unfocus();
                  },
                  onQuickAmountSelected: (amount) =>
                      setState(() => _amountStr = amount.toString()),
                ),
                const CcSpaceSM(),
                CcFormLabel(text: el.tr(CcLocaleKeys.transaction_source_expense)),
                const CcSpaceXS(),
                TransactionWalletSelector(
                  wallets: widget.wallets,
                  selectedWalletId: _selectedWalletId,
                  activeColor: accentColor,
                  onWalletSelected: (id) =>
                      setState(() => _selectedWalletId = id),
                ),
                const CcSpaceLG(),
                _buildSaveButton(context, accentColor),
              ],
            ),
          ),
        ),
        if (_showKeypad)
          MoneyKeypadPanel(
            onKeyPress: _onKeyPress,
            onDelete: _onDelete,
            onClear: () => setState(() => _amountStr = '0'),
            suggestions: MoneyConstants.quickAmounts,
            onSuggestion: (value) =>
                setState(() => _amountStr = value.toString()),
            onDone: () => setState(() => _showKeypad = false),
            activeColor: accentColor,
          ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, Color accentColor) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SizedBox(
          width: double.infinity,
          height: context.respDim(40),
          child: ElevatedButton(
            onPressed: _isValid ? _onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: CcText(
              el.tr(CcLocaleKeys.common_save),
              align: Alignment.center,
              textAlign: TextAlign.center,
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                color: context.ccColorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
