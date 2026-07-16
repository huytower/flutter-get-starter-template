import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/transaction_form_helpers.dart';
import '../../../../core/transaction_form_mixin.dart';
import '../../domain/usecases/create_transfer_usecase.dart';
import 'cc_amount_input_section.dart';
import 'money_keypad_panel.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';
import 'transaction_wallet_selector.dart';

class TransferForm extends StatefulWidget {
  final VoidCallback? onSaved;

  const TransferForm({super.key, this.onSaved});

  @override
  TransferFormState createState() => TransferFormState();
}

class TransferFormState extends State<TransferForm> with TransactionFormMixin {
  Color get accentColor => context.ccColorScheme.secondary;

  static const List<int> _quickAmounts = [
    10000,
    20000,
    30000,
    50000,
    100000,
    200000,
    300000,
    500000,
    1000000,
    2000000,
  ];

  String? _fromWalletId;
  String? _toWalletId;

  @override
  String? get selectedWalletId => _fromWalletId;

  @override
  void Function(String) get onWalletSelected => (id) {
    setState(() {
      if (_toWalletId == id) {
        _toWalletId = _fromWalletId;
      }
      _fromWalletId = id;
    });
  };

  @override
  void initState() {
    super.initState();
    loadWalletsFromController(
      onWalletsLoaded: (walletList) {
        _fromWalletId = walletList.isNotEmpty ? walletList.first.id : null;
        _toWalletId = walletList.length > 1 ? walletList[1].id : null;
      },
    );
  }

  bool get _canSubmit =>
      _fromWalletId != null &&
      _toWalletId != null &&
      _fromWalletId != _toWalletId &&
      amountStr != '0' &&
      amountStr.isNotEmpty;

  Future<void> _onSubmit() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    final params = CreateTransferParams(
      fromWalletId: _fromWalletId ?? '',
      toWalletId: _toWalletId ?? '',
      amount: int.tryParse(amountStr) ?? 0,
      note: composeNote(),
      date: date,
    );

    final result = await getIt<CreateTransferUseCase>().call(params);
    if (!mounted) return;
    setState(() => isSubmitting = false);

    result.when(
      (_) {
        final savedAmount = TransactionFormHelpers.formatAmount(amountStr);
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_transfer_saved,
            namedArgs: {'amount': savedAmount},
          ),
        );
        resetForm();
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
        Expanded(child: _buildScrollableContent(context)),
        if (showKeypad) _buildMoneyKeypadPanel(context),
      ],
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
        vertical: context.respPadding(CcPaddingParams.PAGE_XS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSection(context),
          const CcSpaceLG(),
          _buildFromWalletSection(context),
          const CcSpaceMD(),
          _buildTransferArrow(context),
          const CcSpaceMD(),
          _buildToWalletSection(context),
          const CcSpaceLG(),
          TransactionAdditionalDetailsSection(
            isExpanded: showMoreDetails,
            onToggle: () =>
                setState(() => showMoreDetails = !showMoreDetails),
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
            hasNoteText: noteController.text.isNotEmpty,
            activeColor: accentColor,
          ),
          const CcSpaceXL(),
          TransactionSubmitButton(
            text: el.tr(CcLocaleKeys.transaction_record_transfer),
            isSubmitting: isSubmitting,
            isEnabled: _canSubmit,
            onTap: _onSubmit,
            activeColor: accentColor,
          ),
          const CcSpaceLG(),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    return CcAmountInputSection(
      label: el.tr(CcLocaleKeys.transaction_amount),
      amountStr: amountStr,
      quickAmounts: _quickAmounts,
      isKeypadVisible: showKeypad,
      activeColor: accentColor,
      fieldKey: amountFieldKey,
      onTap: showKeypadAndScroll,
      onQuickAmountSelected: (amount) =>
          setState(() => amountStr = amount.toString()),
    );
  }

  Widget _buildFromWalletSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(el.tr(CcLocaleKeys.transaction_transfer_from)),
        const CcSpaceXS(),
        TransactionWalletSelector(
          wallets: wallets,
          selectedWalletId: _fromWalletId,
          activeColor: accentColor,
          onWalletSelected: onWalletSelected,
        ),
      ],
    );
  }

  Widget _buildTransferArrow(BuildContext context) {
    return Center(
      child: Icon(
        Icons.arrow_downward_rounded,
        color: accentColor,
        size: context.respIconSize(baseSize: 22),
      ),
    );
  }

  Widget _buildToWalletSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(el.tr(CcLocaleKeys.transaction_transfer_to)),
        const CcSpaceXS(),
        TransactionWalletSelector(
          wallets: wallets,
          selectedWalletId: _toWalletId,
          activeColor: accentColor,
          onWalletSelected: (id) => setState(() {
            if (_fromWalletId == id) {
              _fromWalletId = _toWalletId;
            }
            _toWalletId = id;
          }),
        ),
      ],
    );
  }

  Widget _buildMoneyKeypadPanel(BuildContext context) {
    return MoneyKeypadPanel(
      onKeyPress: onKeyPress,
      onDelete: onDelete,
      onClear: () => setState(() => amountStr = '0'),
      suggestions: _quickAmounts,
      onSuggestion: (value) =>
          setState(() => amountStr = value.toString()),
      onDone: hideKeypad,
      activeColor: accentColor,
    );
  }
}
