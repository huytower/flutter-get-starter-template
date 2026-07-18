import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/money_format_helper.dart';
import '../get_x/transaction_controller.dart';

class TransactionWalletSummary extends StatelessWidget {
  const TransactionWalletSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();

    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: context.respIconSize(baseSize: 14),
            color: context.ccColorScheme.onPrimary.withOpacity(0.8),
          ),
          const CcSpaceXS(),
          // Use a fixed width or let the parent Expanded handle overflow
          // Avoid using Flexible here if it's placed inside AnimatedSwitcher/Stack
          CcText(
            '${el.tr(CcLocaleKeys.transaction_wallet)}  ${formatVndShort(controller.walletTotal.value)}',
            textStyle: context.ccTextTheme.bodyMedium?.copyWith(
              color: context.ccColorScheme.onPrimary.withOpacity(0.9),
              fontWeight: CcTypographyParams.semiBold
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
