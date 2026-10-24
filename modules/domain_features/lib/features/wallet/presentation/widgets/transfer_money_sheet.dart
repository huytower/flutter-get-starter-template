import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/di/di.dart';
import '../../../transaction/domain/usecases/create_wallet_transfer_usecase.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../../transaction/presentation/widgets/transaction_submit_button.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';
import 'wallet_strip_card.dart';

class TransferMoneySheet extends StatefulWidget {
  const TransferMoneySheet({super.key, required this.sourceWallet});

  final WalletEntity sourceWallet;

  static Future<void> show(
    BuildContext context, {
    required WalletEntity sourceWallet,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.ccColorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: context.brXl),
      builder: (_) => TransferMoneySheet(sourceWallet: sourceWallet),
    );
  }

  @override
  State<TransferMoneySheet> createState() => _TransferMoneySheetState();
}

class _TransferMoneySheetState extends State<TransferMoneySheet> {
  late WalletController _walletController;
  late WalletEntity _sourceWallet;
  late WalletEntity _destinationWallet;
  String _amount = '0';
  bool _showKeypad = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _walletController = Get.find<WalletController>();
    _sourceWallet = widget.sourceWallet;
    final destinations = _availableWallets(_sourceWallet);
    _destinationWallet = destinations.isEmpty
        ? _sourceWallet
        : destinations.first;
  }

  List<WalletEntity> _availableWallets(WalletEntity excluded) =>
      _walletController.liquidWallets
          .where((wallet) => wallet.id != excluded.id)
          .toList();

  void _swapWallets() {
    setState(() {
      final previousSource = _sourceWallet;
      _sourceWallet = _destinationWallet;
      _destinationWallet = previousSource;
    });
  }

  void _handleKeyPress(String key) {
    setState(() {
      if (_amount == '0') {
        if (key != '0' && key != '000') _amount = key;
      } else {
        _amount += key;
      }
    });
  }

  void _handleDelete() {
    setState(() {
      _amount = _amount.length > 1
          ? _amount.substring(0, _amount.length - 1)
          : '0';
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final amount = int.tryParse(_amount) ?? 0;
    if (amount <= 0) return;

    setState(() => _isSubmitting = true);
    final result = await getIt<CreateWalletTransferUseCase>().call(
      CreateWalletTransferParams(
        sourceWalletId: _sourceWallet.id,
        destinationWalletId: _destinationWallet.id,
        amount: amount,
        categoryLabel: el.tr('transaction.transfer_money'),
        date: DateTime.now(),
      ),
    );

    if (!mounted) return;
    final failure = result.tryGetError();
    if (failure != null) {
      setState(() => _isSubmitting = false);
      CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: el.tr(failure.message),
      );
      return;
    }

    await _walletController.loadWallets(showLoading: false);
    if (!mounted) return;
    Navigator.of(context).pop();
    CcSnackBarHelper.showSuccessSnackBar(
      context: context,
      message: el.tr('transaction.transfer_saved'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final destinations = _availableWallets(_sourceWallet);
    final currencyCode = _walletController.currencyCode.value;
    final amount = int.tryParse(_amount) ?? 0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(
                context.respPadding(CcPaddingParams.SPACE_LG),
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.respDim(24)),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CcFormLabel(
                      text: el.tr('transaction.transfer_money'),
                      color: scheme.primary,
                    ),
                    const CcSpaceSM(),
                    CcAmountInputSection(
                      label: el.tr(CcLocaleKeys.transaction_amount),
                      amountStr: _amount,
                      quickAmounts: MoneyConstants.getWalletQuickAmounts(
                        currencyCode: currencyCode,
                      ),
                      isKeypadVisible: _showKeypad,
                      activeColor: scheme.primary,
                      currencyCode: currencyCode,
                      onTap: () => setState(() => _showKeypad = true),
                      onQuickAmountSelected: (value) =>
                          setState(() => _amount = value.toString()),
                      onClear: () => setState(() => _amount = '0'),
                    ),
                    const CcSpaceMD(),
                    _buildWalletSelector(
                      context,
                      label: el.tr('transaction.transfer_from'),
                      wallet: _sourceWallet,
                      wallets: _walletController.liquidWallets,
                      onSelected: (id) {
                        final selected = _walletController.liquidWallets
                            .firstWhere((item) => item.id == id);
                        if (selected.id == _destinationWallet.id) {
                          _swapWallets();
                        } else {
                          setState(() => _sourceWallet = selected);
                        }
                      },
                    ),
                    Center(
                      child: CcIconButton.bouncing(
                        icon: Icon(
                          Icons.swap_vert_rounded,
                          color: scheme.primary,
                          size: context.respIconSize(baseSize: 24),
                        ),
                        onTap: _swapWallets,
                        tooltip: el.tr('transaction.transfer_swap'),
                      ),
                    ),
                    _buildWalletSelector(
                      context,
                      label: el.tr('transaction.transfer_to'),
                      wallet: _destinationWallet,
                      wallets: destinations,
                      onSelected: (id) {
                        final selected = destinations.firstWhere(
                          (item) => item.id == id,
                        );
                        setState(() => _destinationWallet = selected);
                      },
                    ),
                    const CcSpaceMD(),
                    TransactionSubmitButton(
                      text: el.tr('transaction.transfer_money'),
                      isSubmitting: _isSubmitting,
                      isEnabled: amount > 0 && destinations.isNotEmpty,
                      onTap: _submit,
                      activeColor: scheme.primary,
                      widthFactor: 1,
                      leadingIcon: Icons.swap_vert_rounded,
                    ),
                  ],
                ),
              ),
            ),
            if (_showKeypad)
              MoneyKeypadPanel(
                onKeyPress: _handleKeyPress,
                onDelete: _handleDelete,
                onClear: () => setState(() => _amount = '0'),
                suggestions: MoneyConstants.getWalletQuickAmounts(
                  currencyCode: currencyCode,
                ),
                onSuggestion: (value) =>
                    setState(() => _amount = value.toString()),
                onDone: () => setState(() => _showKeypad = false),
                activeColor: scheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSelector(
    BuildContext context, {
    required String label,
    required WalletEntity wallet,
    required List<WalletEntity> wallets,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: label),
        const CcSpaceXS(),
        WalletStripCard(
          wallets: wallets,
          selectedWalletId: wallet.id,
          activeColor: context.ccColorScheme.primary,
          defaultBgColor: context.verticalGradient(
            context.ccColorScheme.primary,
          ),
          onWalletSelected: onSelected,
        ),
      ],
    );
  }
}
