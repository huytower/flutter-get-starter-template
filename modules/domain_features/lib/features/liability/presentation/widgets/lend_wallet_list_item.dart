import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/helper/budget_name_helper.dart';
import '../../../../core/presentation/widgets/asset_stat_item.dart';
import '../../../../core/presentation/widgets/base_asset_list_item.dart';
import '../../domain/entities/liability_balance_entity.dart';
import '../../domain/entities/liability_entity.dart';

/// List item for a lending balance card.
class LendWalletListItem extends StatelessWidget {
  final LiabilityBalanceEntity balance;
  final bool isEditMode;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LendWalletListItem({
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
    final rawRepaid = liability.principalAmount - balance.outstandingBalance;
    final repaid = rawRepaid < 0 ? 0 : rawRepaid;

    return BaseAssetListItem(
      isEditMode: isEditMode,
      canDelete: canDelete,
      onEdit: onEdit ?? () {},
      onDelete: onDelete ?? () {},
      header: _buildHeader(context, liability),
      stats: [
        AssetStatItem(
          label: el.tr(CcLocaleKeys.liability_received),
          value: repaid,
          color: context.ccColorScheme.onSurfaceVariant,
          currencyCode: liability.currencyCode,
          icon: Image.asset(
            'assets/icon/ic_collect.webp',
            color: context.ccColorScheme.primary,
            width: context.respIconSize(baseSize: 18),
            height: context.respIconSize(baseSize: 18),
          ),
        ),
        CcDividerLine(color: context.ccColorScheme.onSurface.withOpacity(0.06)),
        AssetStatItem(
          label: el.tr(CcLocaleKeys.liability_to_collect),
          value: balance.outstandingBalance.abs(),
          color: PrjColors.liability,
          currencyCode: liability.currencyCode,
          icon: Image.asset(
            'assets/icon/ic_remain.webp',
            width: context.respIconSize(baseSize: 18),
            height: context.respIconSize(baseSize: 18),
          ),
        ),
        CcDividerLine(color: context.ccColorScheme.onSurface.withOpacity(0.06)),
        AssetStatItem(
          label: el.tr(CcLocaleKeys.liability_total_lend),
          value: liability.principalAmount,
          color: PrjColors.liability,
          currencyCode: liability.currencyCode,
          icon: Image.asset(
            'assets/icon/ic_lend.webp',
            color: context.ccColorScheme.primary,
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
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CcIconToken(
              iconDataFromCode(
                liability.categoryIconCode ?? 0,
                fontFamily: liability.categoryIconFamily,
              ),
              size: context.respIconSize(baseSize: 14),
              color: scheme.primary,
            ),
          ),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            BudgetNameHelper.getDisplayName(
              name: liability.categoryLabel,
              categoryNameKey: liability.categoryNameKey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textStyle: context.ccTextTheme.labelLarge?.copyWith(
              fontWeight: CcTypographyParams.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
