import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:message/export_message.dart';

import '../../../wallet/domain/entities/wallet_entity.dart';

class TransactionWalletSelector extends StatelessWidget {
  final List<WalletEntity> wallets;
  final String? selectedWalletId;
  final Color activeColor;
  final Function(String) onWalletSelected;

  const TransactionWalletSelector({
    super.key,
    required this.wallets,
    required this.selectedWalletId,
    required this.activeColor,
    required this.onWalletSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: context.respPadding(CcPaddingParams.PAGE_SM),
          horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
        ),
        child: Text(
          el.tr(CcLocaleKeys.wallet_empty),
          style: context.ccTextTheme.bodyMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Wrap(
      spacing: context.respDim(8),
      runSpacing: context.respDim(8),
      children: wallets.map((wallet) {
        final isSelected = wallet.id == selectedWalletId;
        return CcInkWell(
          onTap: () => onWalletSelected(wallet.id),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.respPadding(CcPaddingParams.PAGE_SM),
              vertical: context.respPadding(CcPaddingParams.PAGE_XS),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withOpacity(0.1)
                  : context.ccColorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(context.respDim(8)),
              border: Border.all(
                color: isSelected ? activeColor : Colors.transparent,
                width: context.respDim(2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...[
                  Icon(
                    Icons.account_balance_wallet,
                    size: context.respDim(16),
                    color: isSelected
                        ? activeColor
                        : context.ccColorScheme.onSurfaceVariant,
                  ),
                  const CcSpaceXS(),
                ],
                Text(
                  wallet.name,
                  style: context.ccTextTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? activeColor
                        : context.ccColorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
