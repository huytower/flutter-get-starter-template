import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/wallet_icon_helper.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Compact horizontal strip of wallet cards shown on the combined Phân bổ tab.
///
/// Each card shows the wallet icon, name, and current book balance.
/// Long-pressing a card calls [onMore] for edit/delete actions.
class WalletStripCard extends StatelessWidget {
  final List<WalletEntity> wallets;
  final void Function(WalletEntity) onMore;

  const WalletStripCard({
    super.key,
    required this.wallets,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return HorizontalFadeScrollView(
      height: context.respDim(110),
      builder: (scrollController) => Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
            vertical: context.respDim(8),
          ),
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final wallet = wallets[index];
            return Padding(
              padding: EdgeInsets.only(right: context.respDim(12)),
              child: Obx(
                () => _WalletCard(
                  wallet: wallet,
                  balance: controller.isBalanceVisible.value
                      ? controller.bookBalanceOf(wallet.id)
                      : null,
                  onMore: () => onMore(wallet),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final WalletEntity wallet;
  final int? balance;
  final VoidCallback onMore;

  const _WalletCard({
    required this.wallet,
    required this.balance,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onMore,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          _buildMainCard(context),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(115),
      padding: EdgeInsets.all(context.respDim(12)),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: CcBorderRadius.lg(context),
        border: Border.all(
          color: scheme.onSurface.withOpacity(0.08),
          width: context.respDim(1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildHeader(context), _buildFooter(context)],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(32),
      height: context.respDim(32),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.12),
        borderRadius: context.brLg,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: CcGlassyGradientIcon()),
          CcIconToken(iconDataFromCode(wallet.iconCode), size: 18),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcText(
          wallet.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
        CcText(
          balance != null ? '${balance!.formatShort()} đ' : '*****',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
