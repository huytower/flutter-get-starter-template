import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';
import 'wallet_display_name.dart';

/// Unified horizontal strip of wallet cards for both Dashboard and Forms.
/// Supports selection, long-press actions, navigation, and "Add New" button.
class WalletStripCard extends StatelessWidget {
  final List<WalletEntity> wallets;
  final String? selectedWalletId;
  final Color activeColor;
  final LinearGradient? defaultBgColor;
  final ValueChanged<String>? onWalletSelected;
  final VoidCallback? onAddNew;
  final String? addNewLabel;
  final String? emptyMessageKey;

  const WalletStripCard({
    super.key,
    required this.wallets,
    this.selectedWalletId,
    this.activeColor = PrjColors.primary,
    this.defaultBgColor,
    this.onWalletSelected,
    this.onAddNew,
    this.addNewLabel,
    this.emptyMessageKey,
  });

  @override
  Widget build(BuildContext context) {
    // Standard singleton pattern for this project's shared controllers.
    final controller = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(getIt<WalletController>());

    if (wallets.isEmpty && onAddNew == null) {
      return _buildEmptyState(context);
    }

    final itemCount = wallets.length + (onAddNew != null ? 1 : 0);

    return HorizontalFadeScrollView(
      height: context.respDim(60),
      builder: (scrollController) => ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const CcSpaceSM(),
        itemBuilder: (context, index) {
          if (onAddNew != null && index == wallets.length) {
            return _buildAddNewItem(context);
          }

          final wallet = wallets[index];
          return _buildReactiveWalletItem(context, wallet, controller);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CcSectionEmptyState(
      message: el.tr(emptyMessageKey ?? CcLocaleKeys.wallet_empty),
      verticalPadding: 12,
      horizontalPadding: CcPaddingParams.SPACE_LG,
    );
  }

  Widget _buildReactiveWalletItem(
    BuildContext context,
    WalletEntity wallet,
    WalletController controller,
  ) {
    final isSelected = wallet.id == selectedWalletId;

    return Obx(() {
      // Observe totalBalance to trigger rebuild when balances change
      controller.totalBalance.value;

      final balance = controller.isBalanceVisible.value
          ? controller.bookBalanceOf(wallet.id)
          : null;

      return CcWalletItem(
        name: wallet.displayName(context),
        iconCode: wallet.iconCode,
        isSelected: isSelected,
        activeColor: activeColor,
        defaultBgColor: defaultBgColor,
        onTap: () => _handleWalletTap(context, wallet.id),
        balanceText: balance != null
            ? TransactionFormHelpers.formatShort(balance)
            : el.tr(CcLocaleKeys.wallet_balance_hidden),
      );
    });
  }

  void _handleWalletTap(BuildContext context, String walletId) {
    if (onWalletSelected != null) {
      onWalletSelected!(walletId);
    } else {
      context.router.push(const LiquidWalletListRoute());
    }
  }

  Widget _buildAddNewItem(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: onAddNew,
      borderRadius: context.brLg,
      child: Container(
        width: context.respDim(115),
        padding: EdgeInsets.all(context.respDim(12)),
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: 0.1),
          borderRadius: context.brLg,
          border: Border.all(
            color: activeColor.withValues(alpha: 0.6),
            width: context.respDim(1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_rounded,
              size: context.respIconSize(baseSize: 20),
              color: activeColor,
            ),
            const CcSpaceXS(),
            Expanded(
              child: CcText(
                addNewLabel ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textStyle: context.ccTextTheme.labelMedium?.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
