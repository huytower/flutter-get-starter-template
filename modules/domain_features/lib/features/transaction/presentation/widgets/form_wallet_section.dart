import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../wallet/presentation/widgets/wallet_strip_card.dart';
import '../get_x/transaction_form_controller.dart';

/// A labelled wallet picker bound to [controller]'s wallets and selection.
/// The form supplies the [label] (it differs per form and direction) and, for
/// a non-default look, [background].
class FormWalletSection extends StatelessWidget {
  const FormWalletSection({
    super.key,
    required this.controller,
    required this.label,
    required this.activeColor,
    this.background,
  });

  final TransactionFormController controller;
  final String label;
  final Color activeColor;
  final LinearGradient? background;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcFormLabel(text: label),
        const CcSpaceXS(),
        Obx(
          () => WalletStripCard(
            wallets: controller.wallets.toList(),
            selectedWalletId: controller.selectedWalletId.value,
            activeColor: activeColor,
            defaultBgColor: background ?? context.verticalGradient(activeColor),
            onWalletSelected: controller.setWalletId,
          ),
        ),
      ],
    );
  }
}
