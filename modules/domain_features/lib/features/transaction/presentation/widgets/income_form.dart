import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:domain_features/features/category/export_category.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/di/di.dart';
import '../../../../core/transaction_form_helpers.dart';
import '../../../../core/transaction_form_mixin.dart';
import '../../../profile/domain/usecases/get_profile_settings_usecase.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../get_x/transaction_controller.dart';
import 'category_selection_section.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'income_quick_amounts.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';
import 'transaction_wallet_selector.dart';

class IncomeForm extends StatefulWidget {
  final VoidCallback? onSaved;

  const IncomeForm({super.key, this.onSaved});

  @override
  IncomeFormState createState() => IncomeFormState();
}

class IncomeFormState extends State<IncomeForm>
    with TransactionFormMixin {
  Color get accentColor => PrjColors.success;

  /// Age-based suggestions (see [IncomeQuickAmounts]); resolved in initState.
  List<int> _quickAmounts = IncomeQuickAmounts.fallback;

  int _categoryKey = 0;
  String? _selectedWalletId;
  CategoryEntity? _selectedCategory;

  @override
  String? get selectedWalletId => _selectedWalletId;

  @override
  void Function(String) get onWalletSelected => (id) {
        setState(() => _selectedWalletId = id);
      };

  @override
  void initState() {
    super.initState();
    loadWalletsFromController(
      onWalletsLoaded: (walletList) {
        _selectedWalletId = walletList.isNotEmpty ? walletList.first.id : null;
      },
    );
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final settings = await getIt<GetProfileSettingsUseCase>().call();
    if (!mounted) return;
    setState(() {
      _quickAmounts = IncomeQuickAmounts.forBirthYear(settings.birthYear);
    });
  }

  bool get _canSubmit =>
      _selectedCategory != null &&
      selectedWalletId != null &&
      amountStr != '0' &&
      amountStr.isNotEmpty;

  Future<void> _onSubmit() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    final params = CreateTransactionParams(
      type: TransactionType.income,
      amount: int.tryParse(amountStr) ?? 0,
      categoryId: _selectedCategory?.id ?? '',
      categoryLabel: _selectedCategory != null
          ? el.tr(_selectedCategory!.nameKey)
          : '',
      walletId: selectedWalletId ?? '',
      note: composeNote(),
      date: date,
    );

    final result = await getIt<CreateTransactionUseCase>().call(params);
    if (!mounted) return;
    setState(() => isSubmitting = false);

    result.when(
      (_) {
        final savedAmount = TransactionFormHelpers.formatAmount(amountStr);
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_income_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        resetForm(
          onReset: () {
            _selectedCategory = null;
            _categoryKey++;
          },
        );
        widget.onSaved?.call();
      },
      (error) => CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: error.message,
      ),
    );
  }

  /// Public method to submit the form (called from app bar)
  void submitForm() {
    if (_canSubmit && !isSubmitting) {
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
              if (showKeypad) hideKeypad();
            },
            child: SingleChildScrollView(
              controller: scrollController,
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
                    activeColor: accentColor,
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
                          amountStr: amountStr,
                          quickAmounts: _quickAmounts,
                          isKeypadVisible: showKeypad,
                          activeColor: accentColor,
                          fieldKey: amountFieldKey,
                          onTap: showKeypadAndScroll,
                          onQuickAmountSelected: (amount) =>
                              setState(() => amountStr = amount.toString()),
                        ),
                        const CcSpaceLG(),
                        buildLabel(
                          el.tr(CcLocaleKeys.transaction_source_income),
                        ),
                        const CcSpaceXS(),
                        TransactionWalletSelector(
                          wallets: wallets,
                          selectedWalletId: selectedWalletId,
                          activeColor: accentColor,
                          onWalletSelected: onWalletSelected,
                        ),
                        const CcSpaceLG(),
                        TransactionAdditionalDetailsSection(
                          isExpanded: showMoreDetails,
                          onToggle: () => setState(
                            () => showMoreDetails = !showMoreDetails,
                          ),
                          selectedDate: date,
                          onDateSelected: (newDate) => setState(() {
                            date = DateTime(
                              newDate.year,
                              newDate.month,
                              newDate.day,
                              date.hour,
                              date.minute,
                            );
                          }),
                          onCalendarTap: pickDate,
                          noteController: noteController,
                          onNoteTap: hideKeypad,
                          activeColor: accentColor,
                        ),
                        const CcSpaceXL(),
                        TransactionSubmitButton(
                          text: el.tr(CcLocaleKeys.transaction_record_income),
                          isSubmitting: isSubmitting,
                          isEnabled: _canSubmit,
                          onTap: _onSubmit,
                          activeColor: accentColor,
                        ),
                        const CcSpaceLG(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showKeypad)
          MoneyKeypadPanel(
            onKeyPress: onKeyPress,
            onDelete: onDelete,
            onClear: () => setState(() => amountStr = '0'),
            suggestions: _quickAmounts,
            onSuggestion: (value) =>
                setState(() => amountStr = value.toString()),
            onDone: hideKeypad,
            activeColor: accentColor,
          ),
      ],
    );
  }

}
