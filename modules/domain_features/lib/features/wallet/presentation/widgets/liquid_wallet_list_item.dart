import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../../core/presentation/widgets/edit_badge.dart';
import '../../../guideline/guideline_controller.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';

/// Horizontal list card for liquid wallets shown on the Wallet list page.
class LiquidWalletListItem extends StatelessWidget {
  final WalletEntity wallet;
  final bool isEditMode;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LiquidWalletListItem({
    super.key,
    required this.wallet,
    this.isEditMode = false,
    this.canDelete = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: context.respDim(CcPaddingParams.SPACE_MD),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          _buildMainCard(context),
          if (isEditMode) ..._buildEditBadges(context),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: context.brLg,
        border: context.borderSubtle,
      ),
      child: Row(
        children: [
          _buildIcon(context),
          const CcSpaceMD(),
          _buildName(context),
          _buildBalance(context),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Stack(
      children: [
        const Positioned.fill(child: CcGlassyGradientIcon()),
        Container(
          padding: EdgeInsets.all(context.respDim(6)),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: CcIconToken(iconDataFromCode(wallet.iconCode), size: 22),
        ),
      ],
    );
  }

  Widget _buildName(BuildContext context) {
    return Expanded(
      child: CcText(
        wallet.name,
        textStyle: context.ccTextTheme.titleSmall?.copyWith(
          fontWeight: CcTypographyParams.bold,
        ),
      ),
    );
  }

  Widget _buildBalance(BuildContext context) {
    final controller = Get.find<WalletController>();
    final scheme = context.ccColorScheme;

    return Obx(() {
      final balance = controller.bookBalanceOf(wallet.id);
      final visible = controller.isBalanceVisible.value;
      return CcText(
        visible ? TransactionFormHelpers.formatShort(balance) : '*****',
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: balance >= 0 ? scheme.onSurface : scheme.error,
        ),
      );
    });
  }

  List<Widget> _buildEditBadges(BuildContext context) {
    final scheme = context.ccColorScheme;
    return [
      if (canDelete)
        Positioned(
          top: context.respDim(-6),
          left: context.respDim(-6),
          child: EditBadge(
            icon: Icons.remove,
            color: scheme.error,
            foregroundColor: scheme.onError,
            onTap: onDelete,
          ),
        ),
      Positioned(
        top: context.respDim(-6),
        right: context.respDim(-6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            EditBadge(
              icon: Icons.edit,
              color: scheme.primary,
              foregroundColor: scheme.onPrimary,
              onTap: onEdit,
            ),
            if (Get.isRegistered<GuidelineController>())
              Obx(() {
                final guideline = Get.find<GuidelineController>();
                final showing =
                    guideline.isTaskActive('wallet_balance') &&
                    wallet.type == WalletType.cash;
                return Positioned(
                  top: -10,
                  right: -10,
                  child: CcGuidelineBadge(
                    showing: showing,
                    color: guideline.currentColor,
                    bounceTrigger: guideline.bounceTrigger,
                    size: 8,
                    label: guideline.bannerDescription,
                    isDescriptionHidden: guideline.isDescriptionHidden.value,
                  ),
                );
              }),
          ],
        ),
      ),
    ];
  }
}
