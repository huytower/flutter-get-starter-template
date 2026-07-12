import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/transaction_form_helpers.dart';
import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../get_x/transaction_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'income_quick_amounts.dart';
import 'money_keypad_panel.dart';
import 'note_field_with_camera.dart';
import 'quick_date_row.dart';
import 'transaction_see_more_section.dart';

class IncomeForm extends StatefulWidget {
  final VoidCallback? onSaved;

  const IncomeForm({super.key, this.onSaved});

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
  bool _showMoreDetails = false;
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

  Future<void> _pickDate() async {
    final picked = await TransactionFormHelpers.pickDate(context, _date);
    if (picked == null) return;
    setState(() {
      _date = TransactionFormHelpers.updateDatePreserveTime(_date, picked);
    });
  }

  String? _composeNote() {
    return TransactionFormHelpers.composeNote(_noteController);
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
        final savedAmount = TransactionFormHelpers.formatAmount(_amountStr);
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
                        CcAmountInputSection(
                          label: el.tr(CcLocaleKeys.transaction_amount),
                          amountStr: _amountStr,
                          quickAmounts: _quickAmounts,
                          isKeypadVisible: _showKeypad,
                          activeColor: _accent,
                          fieldKey: _amountFieldKey,
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
                          onQuickAmountSelected: (amount) =>
                              setState(() => _amountStr = amount.toString()),
                        ),
                        const CcSpaceLG(),
                        _buildLabel(
                          el.tr(CcLocaleKeys.transaction_source_income),
                        ),
                        const CcSpaceXS(),
                        _buildWalletChips(context),
                        const CcSpaceLG(),
                        _buildSeeMoreSection(),
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

  Widget _buildLabel(String text) {
    return CcFormLabel(text: text);
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
    return QuickDateRow(
      selectedDate: _date,
      onDateSelected: (date) => setState(() {
        _date = DateTime(
          date.year,
          date.month,
          date.day,
          _date.hour,
          _date.minute,
        );
      }),
      onCalendarTap: _pickDate,
      accentColor: _accent,
    );
  }

  Widget _buildNoteField() {
    return NoteFieldWithCamera(
      controller: _noteController,
      onTap: () => setState(() => _showKeypad = false),
      onCameraTap: () {
        // TODO: Implement image picker functionality
      },
    );
  }

  Widget _buildSeeMoreSection() {
    return TransactionSeeMoreSection(
      isExpanded: _showMoreDetails,
      onToggle: () => setState(() => _showMoreDetails = !_showMoreDetails),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildTimeRow(), const CcSpaceLG(), _buildNoteField()],
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
