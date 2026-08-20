import 'package:auto_route/auto_route.dart';
import 'package:cc_sdk_ui/export_cc_sdk_ui.dart' hide getIt;
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../../core/navigation/domain_router.gr.dart';
import '../../../guideline/guideline_controller.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';

/// Unified horizontal strip of wallet cards for both Dashboard and Forms.
/// Supports selection, long-press actions, navigation, and "Add New" button.
class CcWalletStripCard extends StatelessWidget {
  final List<WalletEntity> wallets;
  final String? selectedWalletId;
  final Color activeColor;
  final ValueChanged<String>? onWalletSelected;
  final void Function(WalletEntity)? onMore;
  final VoidCallback? onAddNew;
  final String? addNewLabel;
  final String? emptyMessageKey;

  const CcWalletStripCard({
    super.key,
    required this.wallets,
    this.selectedWalletId,
    this.activeColor = PrjColors.primary,
    this.onWalletSelected,
    this.onMore,
    this.onAddNew,
    this.addNewLabel,
    this.emptyMessageKey,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(getIt<WalletController>());

    if (wallets.isEmpty && onAddNew == null) {
      return CcSymmetricPadding(
        horizontal: CcPaddingParams.SPACE_LG,
        vertical: 12,
        child: CcText(
          el.tr(emptyMessageKey ?? CcLocaleKeys.wallet_empty),
          textAlign: TextAlign.center,
          textStyle: context.ccTextTheme.bodySmall?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
          ),
        ),
      );
    }

    final showAddNew = onAddNew != null;
    final itemCount = wallets.length + (showAddNew ? 1 : 0);

    return HorizontalFadeScrollView(
      height: context.respDim(60),
      builder: (scrollController) => ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const CcSpaceSM(),
        itemBuilder: (context, index) {
          if (showAddNew && index == wallets.length) {
            return _buildAddNewItem(context);
          }
          final wallet = wallets[index];
          final isSelected = wallet.id == selectedWalletId;
          return Obx(
            () {
              // Observe totalBalance to trigger rebuild when balances change
              controller.totalBalance.value;
              final balance = controller.isBalanceVisible.value
                  ? controller.bookBalanceOf(wallet.id)
                  : null;
              return _WalletItem(
                wallet: wallet,
                isSelected: isSelected,
                activeColor: activeColor,
                onTap: () {
                  if (onWalletSelected != null) {
                    onWalletSelected!(wallet.id);
                  } else {
                    context.router.push(const LiquidWalletListRoute());
                  }
                },
                onLongPress: onMore != null ? () => onMore!(wallet) : null,
                balance: balance,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddNewItem(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcInkWell(
      onTap: onAddNew,
      borderRadius: context.brLg,
      child: Container(
        width: context.respDim(115),
        padding: EdgeInsets.all(context.respDim(12)),
        decoration: BoxDecoration(
          color: scheme.onSurface.withAlpha(10),
          borderRadius: context.brLg,
          border: Border.all(
            color: activeColor.withAlpha(60),
            width: context.respDim(1),
            style: BorderStyle.solid,
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

class _WalletItem extends StatelessWidget {
  final WalletEntity wallet;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int? balance;

  const _WalletItem({
    required this.wallet,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
    this.onLongPress,
    this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return CcInkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: context.brLg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isSelected)
            Positioned.fill(
              child: CcGlassyGradientBackground(
                centerColor: activeColor.withAlpha(10),
                endColor: activeColor.withAlpha(20),
              ),
            ),
          _buildMainCard(context),
          _buildGuidelineBadge(context),
        ],
      ),
    );
  }

  Widget _buildGuidelineBadge(BuildContext context) {
    if (!Get.isRegistered<GuidelineController>()) return const SizedBox();
    final guideline = Get.find<GuidelineController>();

    final isCashWallet = wallet.type == WalletType.cash;
    final isWalletBalanceActive = guideline.isTaskActive('wallet_balance');
    final showing = isCashWallet && isWalletBalanceActive;

    return Positioned(
      top: -6,
      right: -6,
      child: CcGuidelineBadge(
        showing: showing,
        color: guideline.currentColor,
        bounceTrigger: guideline.bounceTrigger,
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    final scheme = context.ccColorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: activeColor.withAlpha(10),
        borderRadius: context.brLg,
        border: Border.all(
          color: activeColor.withAlpha(isSelected ? 50 : 10),
          width: context.respDim(1),
        ),
      ),
      child: CcPadding(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryIcon(context),
            const CcSpaceSM(),
            _buildDesc(context),
          ],
        ),
        6,
        12,
        12,
        6,
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      width: context.respDim(32),
      height: context.respDim(32),
      decoration: BoxDecoration(
        color: activeColor.withOpacity(0.12),
        borderRadius: context.brLg,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CcGlassyGradientIcon(
              centerColor: activeColor.withAlpha(30),
              endColor: activeColor.withAlpha(50),
            ),
          ),
          CcIconToken(
            color: activeColor,
            iconDataFromCode(wallet.iconCode),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildDesc(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
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
          balance != null
              ? TransactionFormHelpers.formatShort(balance!)
              : '*****',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: isSelected ? activeColor : scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
