import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
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
    if (wallets.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildWalletList(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.respPadding(CcPaddingParams.PAGE_SM),
        horizontal: context.respPadding(CcPaddingParams.PAGE_MD),
      ),
      child: CcText(
        el.tr(CcLocaleKeys.wallet_empty),
        textStyle: context.ccTextTheme.bodyMedium?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
        ),
      ),
    );
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
                borderRadius: context.respDim(16),
                endColor: activeColor.withOpacity(0.2),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: context.respDim(120),
            padding: EdgeInsets.all(context.respDim(12)),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withOpacity(0.1)
                  : scheme.onSurface.withOpacity(0.04),
              borderRadius: BorderRadius.circular(context.respDim(16)),
              border: Border.all(
                color: isSelected
                    ? activeColor.withOpacity(0.2)
                    : scheme.onSurface.withOpacity(0.08),
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
      width: context.respDim(32),
      height: context.respDim(32),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withOpacity(0.12)
            : scheme.onSurface.withOpacity(0.08),
        borderRadius: BorderRadius.circular(context.respDim(20)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected) const Positioned.fill(child: CcGlassyGradientIcon()),
          Icon(
            iconDataFromCode(wallet.iconCode),
            size: context.respIconSize(baseSize: 18),
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
        fontSize: context.respFontSize(11),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
