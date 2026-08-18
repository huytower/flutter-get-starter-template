import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/transaction_form_helpers.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';
import '../widgets/edit_badge.dart';

class LiabilityWalletListItem extends StatelessWidget {
  const LiabilityWalletListItem({
    super.key,
    required this.balance,
    required this.isEditMode,
    required this.onEdit,
    required this.onDelete,
    this.dragHandle,
  });

  final LiabilityBalanceEntity balance;
  final bool isEditMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;
    final liability = balance.liability;
    final isSettled = balance.status == LiabilityStatus.settled;
    final directionColor = liability.isBorrow
        ? PrjColors.warning
        : context.ccColorScheme.secondary;

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
                  _buildHeader(context, liability, directionColor),
                  const CcSpaceMD(),
                  _buildStats(context, balance, isSettled, directionColor, scheme, liability),
                ],
              ),
          ),
          if (isEditMode) ..._buildEditBadges(context),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    LiabilityEntity liability,
    Color directionColor,
  ) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Container(
          width: context.respDim(40),
          height: context.respDim(40),
          decoration: BoxDecoration(
            color: directionColor.withOpacity(0.12),
            borderRadius: context.brLg,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CcGlassyGradientIcon()),
              CcIconToken(
                iconDataFromCode(
                  liability.categoryIconCode ?? 0,
                  fontFamily: liability.categoryIconFamily,
                ),
                size: 20,
                color: directionColor,
              ),
            ],
          ),
        ),
        const CcSpaceMD(),
        Expanded(
          child: CcText(
            liability.categoryLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textStyle: context.ccTextTheme.titleMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
    BuildContext context,
    LiabilityBalanceEntity balance,
    bool isSettled,
    Color directionColor,
    ColorScheme scheme,
    LiabilityEntity liability,
  ) {
    return Column(
      children: [
        _StatItem(
          label: el.tr(CcLocaleKeys.liability_remaining_balance),
          value: balance.outstandingBalance,
          color: isSettled ? scheme.onSurfaceVariant : directionColor,
          icon: liability.isBorrow
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
        ),
        const CcSpaceSM(),
        Divider(
          color: context.ccColorScheme.onSurface.withOpacity(0.06),
          height: 1,
        ),
        const CcSpaceSM(),
        _StatItem(
          label: el.tr(CcLocaleKeys.liability_principal_amount),
          value: liability.principalAmount,
          color: scheme.onSurfaceVariant,
          icon: Icons.account_balance_wallet_rounded,
        ),
      ],
    );
  }

  List<Widget> _buildEditBadges(BuildContext context) {
    final scheme = context.ccColorScheme;
    return [
      if (true)
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
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

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
