import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/money_constants.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../../transaction/presentation/widgets/cc_amount_input_section.dart';
import '../../../transaction/presentation/widgets/money_keypad_panel.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

class AddWalletSheet extends StatefulWidget {
  /// When [wallet] is provided the sheet acts as an edit form; otherwise it
  /// creates a new wallet.
  const AddWalletSheet({super.key, this.wallet});

  final WalletEntity? wallet;

  @override
  State<AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<AddWalletSheet> {
  late final TextEditingController _nameController;
  final _controller = Get.find<WalletController>();

  /// Opening balance as a raw digit string (e.g. "1000000"), mirroring the
  /// transaction amount input pattern.
  String _amountStr = '0';
  bool _showKeypad = false;
  final _amountFieldKey = GlobalKey();

  /// Type of a newly created wallet — the cash wallet is a fixed singleton,
  /// so only bank/credit can be added.
  String _newType = WalletType.bank;

  bool get _isEditing => widget.wallet != null;

  /// The cash wallet keeps its fixed default name and icon.
  bool get _isCash => widget.wallet?.type == WalletType.cash;

  /// Opening balance is locked once the wallet has any transaction (rule 1).
  bool get _balanceLocked =>
      _isEditing && _controller.walletHasTransactions(widget.wallet!.id);

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  Color get _accent => context.ccColorScheme.primary;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _nameController.addListener(() => setState(() {}));
    if (_isEditing) {
      // Use the current book balance for display consistency (the "real"
      // balance the user sees in the list).
      _amountStr = _controller.bookBalanceOf(widget.wallet!.id).toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  void _onAmountTap() {
    // Dismiss the OS keyboard (if the name field is focused) and show the
    // custom money keypad instead — consistent with the transaction pages.
    FocusScope.of(context).unfocus();
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
  }

  void _onSave() async {
    final name = _nameController.text.trim();
    final balance = int.tryParse(_amountStr) ?? 0;

    if (_isEditing) {
      final original = widget.wallet!;
      await _controller.updateWallet(
        WalletEntity(
          id: original.id,
          name: name,
          balance: balance,
          iconCode: original.iconCode,
          type: original.type,
          createdAt: original.createdAt,
        ),
      );
    } else {
      await _controller.addWallet(
        name: name,
        initialBalance: balance,
        iconCode: walletIconFor(_newType).codePoint,
        type: _newType,
      );
    }

    if (mounted) {
      Navigator.pop(context); // Đóng sheet
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: _isEditing
            ? el.tr(CcLocaleKeys.wallet_updated_success)
            : el.tr(CcLocaleKeys.wallet_added_success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_showKeypad) setState(() => _showKeypad = false);
          },
          child: Container(
            padding: EdgeInsets.only(
              left: context.respPadding(CcPaddingParams.SPACE_LG),
              right: context.respPadding(CcPaddingParams.SPACE_LG),
              top: context.respPadding(CcPaddingParams.SPACE_LG),
              bottom:
                  (_showKeypad ? 0 : MediaQuery.of(context).viewInsets.bottom) +
                  context.respPadding(CcPaddingParams.SPACE_LG),
            ),
            decoration: BoxDecoration(
              color: context.ccColorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(child: _buildSheetContent(context)),
          ),
        ),
        if (_showKeypad)
          SafeArea(
            top: false,
            child: MoneyKeypadPanel(
              onKeyPress: _onKeyPress,
              onDelete: _onDelete,
              onClear: () => setState(() => _amountStr = '0'),
              suggestions: MoneyConstants.walletQuickAmounts,
              onSuggestion: (value) =>
                  setState(() => _amountStr = value.toString()),
              onDone: () => setState(() => _showKeypad = false),
              activeColor: _accent,
            ),
          ),
      ],
    );
  }

  Widget _buildSheetContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        const CcSpaceSM(),
        if (!_isEditing) ...[_buildTypeSelector(context), const CcSpaceMD()],
        _buildNameField(),
        const CcSpaceMD(),
        if (_balanceLocked)
          _buildLockedBalance(context)
        else
          _buildAmountSection(context),
        const CcSpaceMD(),
        _buildSaveButton(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return CcText(
      _isEditing
          ? el.tr(CcLocaleKeys.wallet_edit_title)
          : el.tr(CcLocaleKeys.wallet_add_title),
      textStyle: context.ccTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.ccColorScheme.primary,
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      maxLength: 20,
      decoration: InputDecoration(
        labelText: el.tr(CcLocaleKeys.wallet_name),
        hintText: el.tr(CcLocaleKeys.wallet_name_hint),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    return CcAmountInputSection(
      key: const Key('wallet_balance'),
      label: el.tr(CcLocaleKeys.wallet_initial_balance),
      amountStr: _amountStr,
      quickAmounts: MoneyConstants.walletQuickAmounts,
      isKeypadVisible: _showKeypad,
      activeColor: _accent,
      fieldKey: _amountFieldKey,
      onTap: _onAmountTap,
      onQuickAmountSelected: (amount) =>
          setState(() => _amountStr = amount.toString()),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SizedBox(
          height: context.respDim(40),
          child: ElevatedButton(
            onPressed: _isValid ? _onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.ccColorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: CcText(
              el.tr(CcLocaleKeys.wallet_save_info),
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

  /// Read-only display for a balance that can no longer be edited (a wallet
  /// that already has transactions).
  Widget _buildLockedBalance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          el.tr(CcLocaleKeys.wallet_initial_balance),
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const CcSpaceXS(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 54,
          decoration: BoxDecoration(
            color: context.ccColorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.ccColorScheme.outlineVariant.withOpacity(0.2),
            ),
          ),
          alignment: Alignment.center,
          child: CcText(
            '${TransactionFormHelpers.formatAmount(_amountStr)} đ',
            align: Alignment.center,
            textAlign: TextAlign.center,
            textStyle: context.ccTextTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.ccColorScheme.primary,
            ),
          ),
        ),
        const CcSpaceXS(),
        CcText(
          el.tr(CcLocaleKeys.wallet_balance_locked_hint),
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: CcBaseColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    final options = [
      (WalletType.bank, el.tr(CcLocaleKeys.wallet_bank)),
      (WalletType.credit, el.tr(CcLocaleKeys.wallet_credit)),
    ];
    return Row(
      children: options.map((option) {
        final (type, label) = option;
        final isSelected = _newType == type;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _newType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.ccColorScheme.primary
                    : context.ccColorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    walletIconFor(type),
                    size: 16,
                    color: isSelected
                        ? context.ccColorScheme.onPrimary
                        : context.ccColorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  CcText(
                    label,
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? context.ccColorScheme.onPrimary
                          : context.ccColorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
