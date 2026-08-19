import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/presentation/widgets/asset_stat_item.dart';
import '../../../../core/presentation/widgets/base_asset_list_item.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';

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
    final liability = balance.liability;
    final isSettled = balance.status == LiabilityStatus.settled;
    final directionColor = liability.isBorrow
        ? PrjColors.warning
        : context.ccColorScheme.secondary;

    return BaseAssetListItem(
      isEditMode: isEditMode,
      onEdit: onEdit,
      onDelete: onDelete,
      dragHandle: dragHandle,
      header: _buildHeader(context, liability),
      stats: [
        AssetStatItem(
          label: el.tr(CcLocaleKeys.liability_remaining_balance),
          value: balance.outstandingBalance,
          color: isSettled
              ? context.ccColorScheme.onSurfaceVariant
              : directionColor,
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
        AssetStatItem(
          label: el.tr(CcLocaleKeys.liability_principal_amount),
          value: liability.principalAmount,
          color: context.ccColorScheme.onSurfaceVariant,
          icon: Icons.account_balance_wallet_rounded,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, LiabilityEntity liability) {
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
              CcIconToken(
                iconDataFromCode(
                  liability.categoryIconCode ?? 0,
                  fontFamily: liability.categoryIconFamily,
                ),
                size: 20,
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
}
