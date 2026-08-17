import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
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
  final Widget? dragHandle;

  const InvestmentWalletListItem({
    super.key,
    required this.wallet,
    required this.contributed,
    required this.returned,
    this.isEditMode = false,
    this.canDelete = true,
    required this.onEdit,
    required this.onDelete,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    'Investment Item: ${wallet.name} | Contributed: $contributed | Returned: $returned'
        .Log('InvestmentWalletListItem');

    return Padding(
      padding: EdgeInsets.only(
        bottom: context.respPadding(CcPaddingParams.SPACE_MD),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: CcGlassyGradientBackground()),
          Container(
            padding: EdgeInsets.all(context.respDim(16)),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: context.brLg,
              border: Border.all(
                color: scheme.onSurface.withOpacity(0.08),
                width: context.respDim(1),
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.onSurface.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
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
    return Column(
      children: [
        _StatItem(
          label: el.tr(CcLocaleKeys.report_investment_returned),
          value: returned,
          color: PrjColors.success,
          icon: Icons.auto_graph_rounded,
        ),
        const CcSpaceSM(),
        Divider(
          color: context.ccColorScheme.onSurface.withOpacity(0.06),
          height: 1,
        ),
        const CcSpaceSM(),
        _StatItem(
          label: el.tr(CcLocaleKeys.report_investment_contributed),
          value: contributed,
          color: context.ccColorScheme.onSurfaceVariant,
          icon: Icons.eco,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dragHandle != null) ...[dragHandle!, const CcSpaceXS()],
            EditBadge(
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

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: context.respIconSize(baseSize: 18),
          color: color.withOpacity(0.8),
        ),
        const CcSpaceXS(),
        CcText(
          label,
          textStyle: context.ccTextTheme.labelMedium?.copyWith(
            color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
          ),
        ),
        const Spacer(),
        CcText(
          TransactionFormHelpers.formatShort(value),
          textStyle: context.ccTextTheme.labelLarge?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
