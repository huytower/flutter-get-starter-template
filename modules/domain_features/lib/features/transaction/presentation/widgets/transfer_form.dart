import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/di/di.dart';
import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/usecases/create_transfer_usecase.dart';
import '../get_x/transaction_controller.dart';
import '../../../../core/transaction_form_helpers.dart';
import 'cc_amount_input_section.dart';
import 'cc_form_label.dart';
import 'money_keypad_panel.dart';
import 'quick_date_row.dart';
import 'transaction_additional_details_section.dart';
import 'transaction_submit_button.dart';
import 'transaction_wallet_selector.dart';

class TransferForm extends StatefulWidget {
  final VoidCallback? onSaved;

  const TransferForm({super.key, this.onSaved});

  @override
  TransferFormState createState() => TransferFormState();
}

class TransferFormState extends State<TransferForm> {
  Color get _accent => context.ccColorScheme.secondary;

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

  String _amountStr = '0';
  final TextEditingController _noteController = TextEditingController();
  final _scrollController = ScrollController();
  final _amountFieldKey = GlobalKey();

  List<WalletEntity> _wallets = const [];
  String? _fromWalletId;
  String? _toWalletId;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  bool _showKeypad = false;
  bool _showMoreDetails = false;

  @override
  void initState() {
    super.initState();
    _loadWalletsFromController();
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
    _fromWalletId = _wallets.isNotEmpty ? _wallets.first.id : null;
    _toWalletId = _wallets.length > 1 ? _wallets[1].id : null;

    // Listen to wallet changes
    ever(controller.wallets, (wallets) {
      if (mounted) {
        setState(() {
          _wallets = wallets;
          if (_fromWalletId == null && wallets.isNotEmpty) {
            _fromWalletId = wallets.first.id;
          }
          if (_toWalletId == null && wallets.length > 1) {
            _toWalletId = wallets[1].id;
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
      _fromWalletId != null &&
      _toWalletId != null &&
      _fromWalletId != _toWalletId &&
      _amountStr != '0' &&
      _amountStr.isNotEmpty;

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final params = CreateTransferParams(
      fromWalletId: _fromWalletId ?? '',
      toWalletId: _toWalletId ?? '',
      amount: int.tryParse(_amountStr) ?? 0,
      note: _composeNote(),
      date: _date,
    );

    final result = await getIt<CreateTransferUseCase>().call(params);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      (_) {
        final savedAmount = TransactionFormHelpers.formatAmount(_amountStr);
        CcSnackBarHelper.showSuccessSnackBar(
          context: context,
          message: el.tr(
            CcLocaleKeys.transaction_transfer_saved,
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
      _date = DateTime.now();
      _showKeypad = false;
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
                horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
                vertical: context.respPadding(CcPaddingParams.PAGE_XS),
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
                  _buildLabel(el.tr(CcLocaleKeys.transaction_transfer_from)),
                  const CcSpaceXS(),
                  TransactionWalletSelector(
                    wallets: _wallets,
                    selectedWalletId: _fromWalletId,
                    activeColor: _accent,
                    onWalletSelected: (id) => setState(() {
                      if (_toWalletId == id) {
                        _toWalletId = _fromWalletId;
                      }
                      _fromWalletId = id;
                    }),
                  ),
                  const CcSpaceMD(),

                  Center(
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: _accent,
                      size: context.respIconSize(baseSize: 22),
                    ),
                  ),
                  const CcSpaceMD(),

                  _buildLabel(el.tr(CcLocaleKeys.transaction_transfer_to)),
                  const CcSpaceXS(),
                  TransactionWalletSelector(
                    wallets: _wallets,
                    selectedWalletId: _toWalletId,
                    activeColor: _accent,
                    onWalletSelected: (id) => setState(() {
                      if (_fromWalletId == id) {
                        _fromWalletId = _toWalletId;
                      }
                      _toWalletId = id;
                    }),
                  ),
                  const CcSpaceLG(),
                  TransactionAdditionalDetailsSection(
                    isExpanded: _showMoreDetails,
                    onToggle: () => setState(
                      () => _showMoreDetails = !_showMoreDetails,
                    ),
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
                    noteController: _noteController,
                    onNoteTap: () => setState(() => _showKeypad = false),
                    activeColor: _accent,
                  ),
                  const CcSpaceXL(),
                  TransactionSubmitButton(
                    text: el.tr(CcLocaleKeys.transaction_record_transfer),
                    isSubmitting: _isSubmitting,
                    isEnabled: _canSubmit,
                    onTap: _onSubmit,
                    activeColor: _accent,
                  ),
                  const CcSpaceLG(),
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
}
