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
    final repaid = liability.principalAmount - balance.outstandingBalance;
    return BaseAssetListItem(
      isEditMode: isEditMode,
      onEdit: onEdit,
      onDelete: onDelete,
      dragHandle: dragHandle,
      header: _buildHeader(context, liability),
      stats: [
        AssetStatItem(
          label: liability.isBorrow
              ? el.tr(CcLocaleKeys.transaction_record_repay)
              : el.tr(CcLocaleKeys.transaction_record_collect),
          value: repaid,
          color: context.ccColorScheme.onSurfaceVariant,
          icon: Image.asset(
            'assets/icon/${liability.isBorrow ? 'ic_repay.webp' : 'ic_collect.webp'}',
            width: context.respIconSize(baseSize: 18),
            height: context.respIconSize(baseSize: 18),
          ),
        ),
        CcDividerLine(color: context.ccColorScheme.onSurface.withOpacity(0.06)),
        AssetStatItem(
          label: el.tr(CcLocaleKeys.liability_remaining_balance),
          value: balance.outstandingBalance,
          color: PrjColors.liability,
          icon: Image.asset(
            'assets/icon/ic_remain.webp',
            width: context.respIconSize(baseSize: 18),
            height: context.respIconSize(baseSize: 18),
          ),
        ),
        CcDividerLine(color: context.ccColorScheme.onSurface.withOpacity(0.06)),
        AssetStatItem(
          label: liability.isBorrow
              ? el.tr(CcLocaleKeys.liability_borrow)
              : el.tr(CcLocaleKeys.liability_lend),
          value: liability.principalAmount,
          color: PrjColors.liability,
          icon: Image.asset(
            'assets/icon/${liability.isBorrow ? 'ic_borrow.webp' : 'ic_lend.webp'}',
            width: context.respIconSize(baseSize: 18),
            height: context.respIconSize(baseSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, LiabilityEntity liability) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Container(
          width: context.respDim(30),
          height: context.respDim(30),
          decoration: BoxDecoration(borderRadius: context.brMd),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CcGlassyGradientIcon()),
              CcIconToken(
                iconDataFromCode(
                  liability.categoryIconCode ?? 0,
                  fontFamily: liability.categoryIconFamily,
                ),
                size: 14,
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
            textStyle: context.ccTextTheme.labelMedium?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
