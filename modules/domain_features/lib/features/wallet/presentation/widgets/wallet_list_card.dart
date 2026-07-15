import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';
import 'edit_badge.dart';

/// Horizontal list card for wallets shown on the Wallet list page.
class WalletListCard extends StatelessWidget {
  final WalletEntity wallet;
  final bool isEditMode;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WalletListCard({
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
        borderRadius: BorderRadius.circular(context.respDim(20)),
        border: Border.all(
          color: scheme.onSurface.withOpacity(0.08),
          width: context.respDim(1),
        ),
      ),
      child: Row(
        children: [
          _buildIcon(context),
          SizedBox(width: context.respDim(12)),
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
          padding: EdgeInsets.all(context.respDim(10)),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconDataFromCode(wallet.iconCode),
            size: context.respIconSize(baseSize: 22),
            color: scheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildName(BuildContext context) {
    return Expanded(
      child: CcText(
        wallet.name,
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          fontWeight: CcTypographyParams.bold,
          fontSize: context.respFontSize(CcTypographyParams.titleMedium),
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
        visible ? '${balance.formatShort()} đ' : '*****',
        textStyle: context.ccTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: balance >= 0 ? scheme.onSurface : scheme.error,
          fontSize: context.respFontSize(CcTypographyParams.titleMedium),
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
        child: EditBadge(
          icon: Icons.edit,
          color: scheme.primary,
          foregroundColor: scheme.onPrimary,
          onTap: onEdit,
        ),
      ),
    ];
  }
}
