import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';

/// Compact grid card for a liability item in a 2-column grid.
class LiabilityWalletGridCard extends StatelessWidget {
  final LiabilityBalanceEntity balance;
  final bool isEditMode;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LiabilityWalletGridCard({
    super.key,
    required this.balance,
    this.isEditMode = false,
    this.canDelete = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final liability = balance.liability;
    final repaid = liability.principalAmount - balance.outstandingBalance;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildMainCard(context, liability, repaid),
        if (isEditMode) ..._buildEditBadges(context),
      ],
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    LiabilityEntity liability,
    int repaid,
  ) {
    final scheme = context.ccColorScheme;

    return Container(
      padding: EdgeInsets.all(context.respDim(10)),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: context.brMd,
        border: Border.all(
          color: scheme.onSurface.withOpacity(0.08),
          width: context.respDim(1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, liability),
          const CcSpaceXS(),
          Divider(
            color: scheme.onSurface.withOpacity(0.06),
            height: context.respDim(1),
          ),
          const CcSpaceXS(),
          _buildRepaid(context, repaid),
          const CcSpaceXS(),
          _buildRemaining(context),
          const CcSpaceXS(),
          _buildPrincipal(context, liability),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LiabilityEntity liability) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Container(
          width: context.respDim(24),
          height: context.respDim(24),
          decoration: BoxDecoration(borderRadius: context.brSm),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CcGlassyGradientIcon()),
              CcIconToken(
                iconDataFromCode(
                  liability.categoryIconCode ?? 0,
                  fontFamily: liability.categoryIconFamily,
                ),
                size: context.respIconSize(baseSize: 12),
              ),
            ],
          ),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            liability.categoryLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepaid(BuildContext context, int repaid) {
    return Row(
      children: [
        Image.asset(
          'assets/icon/${balance.liability.isBorrow ? 'ic_repay.webp' : 'ic_collect.webp'}',
          width: context.respIconSize(baseSize: 14),
          height: context.respIconSize(baseSize: 14),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            el.tr(CcLocaleKeys.transaction_record_repay),
            maxLines: 1,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        ),
        CcText(
          TransactionFormHelpers.formatShort(repaid),
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: context.ccColorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildRemaining(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/icon/ic_remain.webp',
          width: context.respIconSize(baseSize: 14),
          height: context.respIconSize(baseSize: 14),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            el.tr(CcLocaleKeys.liability_remaining_balance),
            maxLines: 1,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        ),
        CcText(
          TransactionFormHelpers.formatShort(balance.outstandingBalance),
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: PrjColors.debtLoan,
          ),
        ),
      ],
    );
  }

  Widget _buildPrincipal(BuildContext context, LiabilityEntity liability) {
    return Row(
      children: [
        Image.asset(
          'assets/icon/${liability.isBorrow ? 'ic_borrow.webp' : 'ic_lend.webp'}',
          width: context.respIconSize(baseSize: 14),
          height: context.respIconSize(baseSize: 14),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            liability.isBorrow
                ? el.tr(CcLocaleKeys.liability_borrow)
                : el.tr(CcLocaleKeys.liability_lend),
            maxLines: 1,
            textStyle: context.ccTextTheme.labelSmall?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        ),
        CcText(
          TransactionFormHelpers.formatShort(liability.principalAmount),
          textStyle: context.ccTextTheme.labelSmall?.copyWith(
            fontWeight: CcTypographyParams.bold,
            color: PrjColors.debtLoan,
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
          top: context.respDim(-4),
          left: context.respDim(-4),
          child: _EditBadge(
            icon: Icons.remove,
            color: scheme.error,
            onTap: onDelete,
          ),
        ),
      Positioned(
        top: context.respDim(-4),
        right: context.respDim(-4),
        child: _EditBadge(
          icon: Icons.edit,
          color: scheme.primary,
          onTap: onEdit,
        ),
      ),
    ];
  }
}

class _EditBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _EditBadge({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return CcBouncing(
      onTap: onTap,
      child: Container(
        width: context.respDim(20),
        height: context.respDim(20),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: scheme.surface,
            width: context.respDim(1.5),
          ),
        ),
        child: Icon(
          icon,
          color: scheme.onPrimary,
          size: context.respIconSize(baseSize: 12),
        ),
      ),
    );
  }
}
