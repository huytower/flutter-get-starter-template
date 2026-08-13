import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:flutter/material.dart';
import 'package:theme/data/data_source/color/prj_color.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../../../core/helper/wallet_icon_helper.dart';
import '../../domain/entities/wallet_entity.dart';
import 'edit_badge.dart';

class InvestmentWalletListItem extends StatelessWidget {
  final WalletEntity wallet;
  final int contributed;
  final int returned;
  final bool isEditMode;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InvestmentWalletListItem({
    super.key,
    required this.wallet,
    required this.contributed,
    required this.returned,
    this.isEditMode = false,
    this.canDelete = true,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.respDim(6),
        vertical: context.respDim(CcPaddingParams.SPACE_XS),
      ).copyWith(bottom: context.respDim(CcPaddingParams.SPACE_MD)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          Container(
            padding: EdgeInsets.all(context.respDim(16)),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: context.brLg,
              border: Border.all(
                color: scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const CcSpaceMD(),
                _buildStats(context),
              ],
            ),
          ),
          if (isEditMode) ..._buildEditBadges(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Container(
          width: context.respDim(40),
          height: context.respDim(40),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            borderRadius: context.brLg,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CcGlassyGradientIcon()),
              CcIconToken(iconDataFromCode(wallet.iconCode), size: 20),
            ],
          ),
        ),
        const CcSpaceMD(),
        Expanded(
          child: CcText(
            wallet.name,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        // ── Return Section ───────────────────────────────────────────────────
        Icon(
          Icons.auto_graph_rounded,
          size: context.respIconSize(baseSize: 18),
          color: PrjColors.success.withOpacity(0.8),
        ),
        const CcSpaceXS(),
        CcText(
          TransactionFormHelpers.formatShort(returned),
          textStyle: context.ccTextTheme.titleSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: PrjColors.success,
          ),
        ),
        const CcSpaceXL(),
        // ── Contribute Section ───────────────────────────────────────────────
        Icon(
          Icons.token_rounded,
          size: context.respIconSize(baseSize: 18),
          color: scheme.onSurfaceVariant.withOpacity(0.8),
        ),
        const CcSpaceXS(),
        CcText(
          TransactionFormHelpers.formatShort(contributed),
          textStyle: context.ccTextTheme.titleSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
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
