import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/wallet_icon_helper.dart';
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
    return _buildWalletList(context);
  }

  Widget _buildWalletList(BuildContext context) {
    return HorizontalFadeScrollView(
      height: context.respDim(45),
      builder: (scrollController) => ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        itemCount: wallets.length,
        separatorBuilder: (_, _) => const CcSpaceSM(),
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          final isSelected = wallet.id == selectedWalletId;
          return _buildWalletItem(context, wallet, isSelected);
        },
      ),
    );
  }

  Widget _buildWalletItem(
    BuildContext context,
    WalletEntity wallet,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return GestureDetector(
      onTap: () => onWalletSelected(wallet.id),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                centerColor: activeColor.withAlpha(30),
                endColor: activeColor.withAlpha(50),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(120),
            padding: EdgeInsets.all(context.respDim(12)),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withAlpha(10)
                  : scheme.onSurface.withAlpha(10),
              borderRadius: context.brLg,
              border: Border.all(
                color: isSelected
                    ? activeColor.withAlpha(20)
                    : scheme.onSurface.withAlpha(10),
                width: context.respDim(1),
              ),
            ),
            child: Row(
              children: [
                _buildWalletIcon(context, wallet, isSelected),
                const CcSpaceXS(),
                Expanded(child: _buildWalletName(context, wallet, isSelected)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletIcon(
    BuildContext context,
    WalletEntity wallet,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(35),
      height: context.respDim(35),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withAlpha(10)
            : scheme.onSurface.withAlpha(10),
        borderRadius: context.brLg,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientIcon(
                centerColor: activeColor.withAlpha(30),
                endColor: activeColor.withAlpha(50),
              ),
            ),
          Icon(
            iconDataFromCode(wallet.iconCode),
            size: context.respIconSize(baseSize: 20),
            color: isSelected ? activeColor : scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletName(
    BuildContext context,
    WalletEntity wallet,
    bool isSelected,
  ) {
    final scheme = context.ccColorScheme;

    return CcText(
      wallet.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textStyle: context.ccTextTheme.labelMedium?.copyWith(
        color: isSelected ? activeColor : scheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
