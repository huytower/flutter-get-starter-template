import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:domain_features/core/domain/entities/wallet_entity.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/currency/money_formatter.dart';
import '../../../../core/presentation/helper/transaction_form_helpers.dart';
import '../../../../core/presentation/widgets/prj_flip_card.dart';
import '../get_x/wallet_controller.dart';
import 'wallet_display_name.dart';

/// Horizontal list card for liquid wallets shown on the Wallet list page.
///
/// Tapping the card flips it up-down (flashcard style) to toggle between
/// compacted balance (e.g. `3.6M`) and full exact balance (e.g. `3,596,693 đ`).
class LiquidWalletListItem extends StatelessWidget {
  final WalletEntity wallet;
  final bool hasEditMode;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTransfer;

  const LiquidWalletListItem({
    super.key,
    required this.wallet,
    this.hasEditMode = false,
    this.canDelete = true,
    this.onEdit,
    this.onDelete,
    this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: context.respDim(CcPaddingParams.SPACE_MD),
      ),
      child: PrjFlipCard(
        enabled: !hasEditMode,
        front: _buildCardSide(context, showFullBalance: false),
        back: _buildCardSide(context, showFullBalance: true),
      ),
    );
  }

  Widget _buildCardSide(BuildContext context, {required bool showFullBalance}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: CcGlassyGradientBackground()),
        _buildMainCard(context, showFullBalance: showFullBalance),
        if (hasEditMode) ..._buildEditBadges(context),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, {required bool showFullBalance}) {
    final scheme = context.ccColorScheme;

    return Container(
      padding: EdgeInsets.all(context.respPadding(CcPaddingParams.SPACE_MD)),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: context.brLg,
        border: context.borderSubtle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIcon(context),
          SizedBox(width: context.respPadding(CcPaddingParams.SPACE_SM)),
          _buildName(context),
          const Spacer(),
          _buildBalance(context, showFullBalance: showFullBalance),
          SizedBox(width: context.respPadding(CcPaddingParams.SPACE_XS)),
          CcIconButton.bouncing(
            width: context.respIconSize(baseSize: 20),
            icon: Icon(
              Icons.swap_vert_rounded,
              color: scheme.primary,
              size: context.respIconSize(baseSize: 20),
            ),
            onTap: onTransfer ?? () {},
            tooltip: el.tr('transaction.transfer_money'),
          ),
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
        wallet.displayName(context),
        align: Alignment.centerLeft,
        textAlign: TextAlign.start,
        textStyle: context.ccTextTheme.titleSmall?.copyWith(
          fontWeight: CcTypographyParams.bold,
        ),
      ),
    );
  }

  Widget _buildBalance(BuildContext context, {required bool showFullBalance}) {
    final controller = Get.find<WalletController>();
    final scheme = context.ccColorScheme;

    return Obx(() {
      final balance = controller.displayBookBalanceOf(wallet.id);
      final visible = controller.hasBalanceVisible.value;
      final code = controller.currencyCode.value;
      final label = !visible
          ? '*****'
          : showFullBalance
          ? formatCurrencyWithSymbol(balance, currencyCode: code)
          : TransactionFormHelpers.formatShortWithSymbol(
              balance,
              currencyCode: code,
            );
      return CcText(
        label,
        maxLines: 1,
        align: Alignment.centerRight,
        textAlign: TextAlign.end,
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
          child: CcEditBadge(
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
            CcEditBadge(
              icon: Icons.edit,
              color: scheme.primary,
              foregroundColor: scheme.onPrimary,
              onTap: onEdit,
            ),
          ],
        ),
      ),
    ];
  }
}
