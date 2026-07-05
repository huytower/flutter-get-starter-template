import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import 'category_selection_section.dart';
import 'money_keypad_panel.dart';

class ExpenseForm extends StatefulWidget {
  /// Called after a transaction is saved (e.g. to refresh history).
  final VoidCallback? onSaved;

  const ExpenseForm({super.key, this.onSaved});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  static const Color _accent = Color(0xFFE54D42);

  String _amountStr = '0';
  final TextEditingController _noteController = TextEditingController();

  List<WalletEntity> _wallets = const [];
  String? _selectedWalletId;
  CategoryEntity? _selectedCategory;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  bool _showKeypad = false;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    final result = await getIt<WalletRepository>().getWallets();
    if (!mounted) return;
    result.when((wallets) {
      setState(() {
        _wallets = wallets;
        _selectedWalletId = wallets.isNotEmpty ? wallets.first.id : null;
      });
    }, (_) {});
  }

  void _onKeyPress(String key) {
    setState(() {
      if (_amountStr == '0') {
        if (key != '0' && key != '000') {
          _amountStr = key;
        }
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

  String _formatAmount(String amount) {
    if (amount == '0') return '0';
    final formatter = el.NumberFormat('#,###', 'vi_VN');
    return formatter.format(int.parse(amount));
  }

  Future<void> _pickDate() async {
    // Only today or earlier — a transaction can't be recorded in the future
    // (spec: "cho phép điều chỉnh lùi ngày").
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      );
    });
  }

  String? _composeNote() {
    final note = _noteController.text.trim();
    return note.isEmpty ? null : note;
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final params = CreateTransactionParams(
      type: 'expense',
      amount: int.tryParse(_amountStr) ?? 0,
      categoryId: _selectedCategory?.id ?? '',
      categoryLabel: _selectedCategory != null
          ? el.tr(_selectedCategory!.nameKey)
          : '',
      walletId: _selectedWalletId ?? '',
      note: _composeNote(),
      date: _date,
    );

    final result = await getIt<CreateTransactionUseCase>().call(params);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      (_) {
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(CcLocaleKeys.transaction_record_expense),
        );
        _resetForm();
        widget.onSaved?.call();
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: error.message,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _amountStr = '0';
      _noteController.clear();
      _selectedCategory = null;
      _date = DateTime.now();
      _showKeypad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (_showKeypad) setState(() => _showKeypad = false);
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: context.respPadding(CcPaddingParams.PAGE_XS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategorySelectionSection(
                    activeColor: _accent,
                    onCategorySelected: (category) =>
                        setState(() => _selectedCategory = category),
                  ),
                  const CcSpaceLG(),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(el.tr(CcLocaleKeys.transaction_amount)),
                        const CcSpaceXS(),
                        _buildAmountField(),
                        const CcSpaceLG(),

                        _buildLabel(
                          el.tr(CcLocaleKeys.transaction_source_expense),
                        ),
                        const CcSpaceXS(),
                        _buildSourceDropdown(),
                        const CcSpaceLG(),

                        _buildLabel('Ghi chú'),
                        const CcSpaceXS(),
                        _buildTextField(
                          _noteController,
                          el.tr(CcLocaleKeys.transaction_enter_content),
                        ),
                        const CcSpaceLG(),

                        _buildLabel(el.tr(CcLocaleKeys.transaction_time)),
                        const CcSpaceXS(),
                        _buildTimeRow(),
                        const CcSpaceXL(),

                        _buildSubmitButton(),
                        const CcSpaceLG(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showKeypad)
          MoneyKeypadPanel(
            onKeyPress: _onKeyPress,
            onDelete: _onDelete,
            onClear: () => setState(() => _amountStr = '0'),
            onSuggestion: (value) =>
                setState(() => _amountStr = value.toString()),
            onDone: () => setState(() => _showKeypad = false),
            activeColor: _accent,
          ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return CcText(
      text,
      textStyle: context.ccTextTheme.labelMedium?.copyWith(
        color: Colors.grey[700],
        fontWeight: FontWeight.bold,
        fontSize: context.respFontSize(12),
      ),
    );
  }

  Widget _buildAmountField() {
    return GestureDetector(
      onTap: () => setState(() => _showKeypad = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _showKeypad ? _accent : Colors.grey.withOpacity(0.2),
            width: _showKeypad ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.centerRight,
        child: CcText(
          _formatAmount(_amountStr),
          textStyle: context.ccTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _accent,
            fontSize: context.respFontSize(24),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceDropdown() {
    if (_wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 48,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: CcText(
          el.tr(CcLocaleKeys.common_no_data),
          textStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
            fontSize: context.respFontSize(13),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWalletId,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: context.ccTextTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontSize: context.respFontSize(14),
          ),
          items: _wallets.map((wallet) {
            return DropdownMenuItem<String>(
              value: wallet.id,
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 18,
                    color: _accent,
                  ),
                  const CcSpaceSM(),
                  CcText(
                    wallet.name,
                    textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                      fontSize: context.respFontSize(14),
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedWalletId = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        onTap: () => setState(() => _showKeypad = false),
        style: context.ccTextTheme.bodyMedium?.copyWith(
          fontSize: context.respFontSize(14),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: context.ccTextTheme.bodyMedium?.copyWith(
            color: Colors.grey[400],
            fontSize: context.respFontSize(13),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            CcText(
              el.DateFormat('dd/MM/yyyy HH:mm').format(_date),
              textStyle: context.ccTextTheme.bodyMedium?.copyWith(
                fontSize: context.respFontSize(13),
              ),
            ),
            const Spacer(),
            Icon(Icons.calendar_month, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return CcInteractBtnWrapper(
      useDebounce: true,
      isBouncing: true,
      onTap: _onSubmit,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accent.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _isSubmitting
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : CcText(
                el.tr(CcLocaleKeys.transaction_record_expense),
                align: Alignment.center,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: context.respFontSize(15),
                ),
              ),
      ),
    );
  }
}
