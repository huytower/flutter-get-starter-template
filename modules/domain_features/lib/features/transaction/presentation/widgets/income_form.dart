import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../get_x/transaction_controller.dart';
import 'category_selection_section.dart';
import 'income_quick_amounts.dart';
import 'money_keypad_panel.dart';

class IncomeForm extends StatefulWidget {
  final VoidCallback? onSaved;
  final GlobalKey<IncomeFormState>? formKey;

  const IncomeForm({super.key, this.onSaved, this.formKey});

  @override
  IncomeFormState createState() => IncomeFormState();
}

class IncomeFormState extends State<IncomeForm> {
  Color get _accent => PrjColors.success;

  /// Age-based suggestions (see [IncomeQuickAmounts]); resolved in initState.
  List<int> _quickAmounts = IncomeQuickAmounts.fallback;

  String _amountStr = '0';
  final TextEditingController _noteController = TextEditingController();
  final _scrollController = ScrollController();
  final _amountFieldKey = GlobalKey();

  List<WalletEntity> _wallets = const [];
  String? _selectedWalletId;
  CategoryEntity? _selectedCategory;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  bool _showKeypad = false;
  int _categoryKey = 0;

  @override
  void initState() {
    super.initState();
    _loadWalletsFromController();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    if (!mounted) return;
    setState(() {
      _quickAmounts = IncomeQuickAmounts.forBirthYear(settings.birthYear);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadWalletsFromController() {
    // Use shared wallet data from controller to avoid duplicate API calls
    final controller = Get.find<TransactionController>();
    _wallets = controller.wallets;
    _selectedWalletId = _wallets.isNotEmpty ? _wallets.first.id : null;

    // Listen to wallet changes
    ever(controller.wallets, (wallets) {
      if (mounted) {
        setState(() {
          _wallets = wallets;
          if (_selectedWalletId == null && wallets.isNotEmpty) {
            _selectedWalletId = wallets.first.id;
          }
        });
      }
    });
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

  String _formatAmount(String amount) {
    if (amount == '0') return '0';
    final formatter = el.NumberFormat('#,###', 'vi_VN');
    return formatter.format(int.parse(amount));
  }

  Future<void> _pickDate() async {
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

  bool get _canSubmit =>
      _selectedCategory != null &&
      _selectedWalletId != null &&
      _amountStr != '0' &&
      _amountStr.isNotEmpty;

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final params = CreateTransactionParams(
      type: 'income',
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
        final savedAmount = _formatAmount(_amountStr);
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_income_saved,
            namedArgs: {'amount': savedAmount},
          ),
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
      _categoryKey++;
    });
  }

  /// Public method to submit the form (called from app bar)
  void submitForm() {
    if (_canSubmit && !_isSubmitting) {
      _onSubmit();
    }
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
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                vertical: context.respPadding(CcPaddingParams.PAGE_XS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategorySelectionSection(
                    key: ValueKey(_categoryKey),
                    type: CategoryType.income,
                    autoSelectFirst: true,
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
                        const CcSpaceXS(),
                        _buildQuickAmounts(),
                        const CcSpaceLG(),
                        _buildLabel(
                          el.tr(CcLocaleKeys.transaction_source_income),
                        ),
                        const CcSpaceXS(),
                        _buildWalletChips(context),
                        const CcSpaceLG(),
                        _buildLabel(el.tr(CcLocaleKeys.transaction_time)),
                        const CcSpaceXS(),
                        _buildTimeRow(),
                        const CcSpaceLG(),
                        _buildLabel(el.tr(CcLocaleKeys.transaction_note)),
                        const CcSpaceXS(),
                        _buildNoteField(),
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
            suggestions: _quickAmounts,
            onSuggestion: (value) =>
                setState(() => _amountStr = value.toString()),
            onDone: () => setState(() => _showKeypad = false),
            activeColor: _accent,
          ),
      ],
    );
  }

  String _formatShort(int amount) {
    if (amount >= 1000000) return '${amount ~/ 1000000}tr';
    if (amount >= 1000) return '${amount ~/ 1000}k';
    return amount.toString();
  }

  Widget _buildQuickAmounts() {
    return HorizontalFadeScrollView(
      height: context.respDim(36),
      builder: (scrollController) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        child: Row(
          children: _quickAmounts.map((amount) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _amountStr = amount.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CcText(
                    _formatShort(amount),
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: _accent,
                      fontWeight: FontWeight.w600,
                      fontSize: context.respFontSize(12),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
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
      key: _amountFieldKey,
      onTap: () {
        setState(() => _showKeypad = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _amountFieldKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      },
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
        alignment: Alignment.center,
        child: CcText(
          '${_formatAmount(_amountStr)} đ',
          align: Alignment.center,
          textAlign: TextAlign.center,
          textStyle: context.ccTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _accent,
            fontSize: context.respFontSize(24),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletChips(BuildContext context) {
    if (_wallets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
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

    return HorizontalFadeScrollView(
      height: context.respDim(44),
      builder: (scrollController) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        child: Row(
          children: _wallets.map((wallet) {
            final isSelected = _selectedWalletId == wallet.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedWalletId = wallet.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _accent : const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        walletIconFor(wallet.type),
                        size: 14,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      CcText(
                        wallet.name,
                        textStyle: context.ccTextTheme.labelMedium?.copyWith(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: context.respFontSize(13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
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

  Widget _buildNoteField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _noteController,
        onTap: () => setState(() => _showKeypad = false),
        style: context.ccTextTheme.bodyMedium?.copyWith(
          fontSize: context.respFontSize(14),
        ),
        decoration: InputDecoration(
          hintText: el.tr(CcLocaleKeys.transaction_note_hint),
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

  Widget _buildSubmitButton() {
    final enabled = _canSubmit && !_isSubmitting;
    return CcInteractBtnWrapper(
      useDebounce: true,
      isBouncing: enabled,
      onTap: enabled ? _onSubmit : () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: enabled ? _accent : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _accent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
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
                el.tr(CcLocaleKeys.transaction_record_income),
                align: Alignment.center,
                textAlign: TextAlign.center,
                textStyle: context.ccTextTheme.titleMedium?.copyWith(
                  color: enabled ? Colors.white : Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: context.respFontSize(15),
                ),
              ),
      ),
    );
  }
}
