import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/wallet_controller.dart';

class AddWalletSheet extends StatefulWidget {
  const AddWalletSheet({super.key});

  @override
  State<AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<AddWalletSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _controller = Get.find<WalletController>();

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

    final balance = double.tryParse(balanceStr) ?? 0.0;

    await _controller.addWallet(
      name: name,
      initialBalance: balance,
      iconCode: Icons.account_balance_wallet.codePoint,
    );

    if (mounted) {
      Navigator.pop(context); // Đóng sheet
      CcSnackBarHelper.showSuccessSnackBar(
        context: context,
        message: 'Đã thêm ví mới',
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
            'Thêm ví mới',
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
            decoration: InputDecoration(
              labelText: 'Số dư đầu kỳ',
              hintText: 'Ví dụ: 1000000',
              suffixText: 'đ',
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
