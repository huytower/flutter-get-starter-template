import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/icon_utils.dart';
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
  late final TextEditingController _balanceController;
  final _controller = Get.find<WalletController>();

  /// Type of a newly created wallet — the cash wallet is a fixed singleton,
  /// so only bank/credit can be added.
  String _newType = WalletType.bank;

  bool get _isEditing => widget.wallet != null;

  /// The cash wallet keeps its fixed default name and icon.
  bool get _isCash => widget.wallet?.type == WalletType.cash;

  /// Opening balance is locked once the wallet has any transaction (rule 1).
  bool get _balanceLocked =>
      _isEditing && _controller.walletHasTransactions(widget.wallet!.id);

  bool get _isValid {
    if (_nameController.text.trim().isEmpty) return false;
    if (!_balanceLocked) {
      final balanceStr = _balanceController.text.trim();
      if (balanceStr.isNotEmpty && int.tryParse(balanceStr) == null) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet != null ? widget.wallet!.balance.toString() : '',
    );
    _nameController.addListener(() => setState(() {}));
    _balanceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final name = _nameController.text.trim();
    final balance = int.tryParse(_balanceController.text.trim()) ?? 0;

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
    return Container(
      padding: EdgeInsets.only(
        left: context.respPadding(CcPaddingParams.SPACE_LG),
        right: context.respPadding(CcPaddingParams.SPACE_LG),
        top: context.respPadding(CcPaddingParams.SPACE_LG),
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            context.respPadding(CcPaddingParams.SPACE_LG),
      ),
      decoration: BoxDecoration(
        color: context.ccColorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CcText(
            _isEditing
                ? el.tr(CcLocaleKeys.wallet_edit_title)
                : el.tr(CcLocaleKeys.wallet_add_title),
            textStyle: context.ccTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.ccColorScheme.primary,
            ),
          ),
          const CcSpaceMD(),
          if (!_isEditing) ...[_buildTypeSelector(context), const CcSpaceMD()],
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: el.tr(CcLocaleKeys.wallet_name),
              hintText: el.tr(CcLocaleKeys.wallet_name_hint),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const CcSpaceMD(),
          TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            readOnly: _balanceLocked,
            enabled: !_balanceLocked,
            decoration: InputDecoration(
              labelText: el.tr(CcLocaleKeys.wallet_initial_balance),
              hintText: el.tr(CcLocaleKeys.wallet_initial_balance_hint),
              suffixText: 'đ',
              helperText: _balanceLocked
                  ? el.tr(CcLocaleKeys.wallet_balance_locked_hint)
                  : null,
              helperMaxLines: 2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const CcSpaceLG(),
          SizedBox(
            width: double.infinity,
            height: context.respDim(50),
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
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
                    : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    walletIconFor(type),
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  CcText(
                    label,
                    textStyle: context.ccTextTheme.labelMedium?.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[800],
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
