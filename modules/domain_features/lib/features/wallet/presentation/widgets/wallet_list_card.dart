import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/util/icon_utils.dart';
import '../../domain/entities/wallet_entity.dart';
import '../get_x/wallet_controller.dart';
import 'edit_badge.dart';

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
    final scheme = context.ccColorScheme;
    final bgColor = Color.alphaBlend(
      scheme.primary.withOpacity(0.10),
      scheme.surface,
    );

    return Container(
      margin: EdgeInsets.only(bottom: context.respDim(12)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: context.respDim(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.respDim(16)),
              child: _buildCardContent(context, bgColor),
            ),
          ),
          if (isEditMode) ...[
            if (canDelete)
              Positioned(
                top: 0,
                left: 0,
                child: EditBadge(
                  icon: Icons.remove,
                  color: scheme.error,
                  foregroundColor: scheme.onError,
                  onTap: onDelete,
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              child: EditBadge(
                icon: Icons.edit,
                color: scheme.primary,
                foregroundColor: scheme.onPrimary,
                onTap: onEdit,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Color bgColor) {
    final scheme = context.ccColorScheme;
    final controller = Get.find<WalletController>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      color: bgColor,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.respDim(10)),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconDataFromCode(wallet.iconCode),
              size: context.respIconSize(baseSize: 22),
              color: scheme.primary,
            ),
          ),
          SizedBox(width: context.respDim(12)),
          Expanded(
            child: CcText(
              wallet.name,
              textStyle: context.ccTextTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.respFontSize(CcTypographyParams.titleMedium),
              ),
            ),
          ),
          Obx(() {
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
          }),
        ],
      ),
    );
  }
}
