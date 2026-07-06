import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';

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

  bool get _isEditing => widget.wallet != null;

  /// Opening balance is locked once the wallet has any transaction (rule 1).
  bool get _balanceLocked =>
      _isEditing && _controller.walletHasTransactions(widget.wallet!.id);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet != null
          ? widget.wallet!.balance.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _onSave() async {
    final name = _nameController.text.trim();
    final balanceStr = _balanceController.text.trim();

    if (name.isEmpty) {
      CcSnackBarHelper.showErrorSnackBar(
        context: context,
        message: 'Vui lòng nhập tên ví',
      );
      return;
    }

    final balance = int.tryParse(balanceStr) ?? 0;

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
        iconCode: Icons.account_balance_wallet.codePoint,
      );
    }

    if (mounted) {
      Navigator.pop(context); // Đóng sheet
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: _isEditing ? 'Đã cập nhật ví' : 'Đã thêm ví mới',
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
            _isEditing ? 'Sửa ví' : 'Thêm ví mới',
            textStyle: context.ccTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.ccColorScheme.primary,
            ),
          ),
          const CcSpaceMD(),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên ví',
              hintText: 'Ví dụ: Tiền mặt, Techcombank...',
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
              labelText: 'Số dư đầu kỳ',
              hintText: 'Ví dụ: 1000000',
              suffixText: 'đ',
              helperText: _balanceLocked
                  ? 'Không thể sửa số dư đầu kỳ khi ví đã có giao dịch'
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
            height: 50,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.ccColorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const CcText(
                'Lưu thông tin',
                textStyle: TextStyle(
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
}
