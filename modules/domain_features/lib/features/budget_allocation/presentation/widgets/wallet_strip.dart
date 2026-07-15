import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/horizontal_fade_scroll_view.dart';
import '../../../../core/util/icon_utils.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/get_x/wallet_controller.dart';

/// Compact horizontal strip of wallet cards shown on the combined Phân bổ tab.
///
/// Each card shows the wallet icon, name, and current book balance.
/// Long-pressing a card calls [onMore] for edit/delete actions.
class WalletStrip extends StatelessWidget {
  final List<WalletEntity> wallets;
  final void Function(WalletEntity) onMore;

  const WalletStrip({super.key, required this.wallets, required this.onMore});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return HorizontalFadeScrollView(
      height: context.respDim(90),
      builder: (scrollController) => Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
          ),
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final wallet = wallets[index];
            return Padding(
              padding: EdgeInsets.only(right: context.respDim(10)),
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
    final scheme = context.ccColorScheme;

    return GestureDetector(
      onLongPress: onMore,
      child: Container(
        width: context.respDim(110),
        padding: EdgeInsets.all(context.respDim(12)),
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(context.respDim(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(context.respDim(6)),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconDataFromCode(wallet.iconCode),
                size: context.respIconSize(baseSize: 18),
                color: scheme.primary,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CcText(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: context.respFontSize(
                      CcTypographyParams.labelMedium,
                    ),
                  ),
                ),
                CcText(
                  balance != null
                      ? '${balance!.formatShort()} đ'
                      : '*****',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textStyle: context.ccTextTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                    fontSize: context.respFontSize(
                      CcTypographyParams.labelMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
