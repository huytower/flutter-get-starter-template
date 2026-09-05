import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';
import 'package:theme/export_theme.dart';

import '../../../../core/presentation/widgets/asset_stat_item.dart';
import '../../../../core/presentation/widgets/base_asset_list_item.dart';
import '../../domain/entities/wallet_entity.dart';
import 'wallet_display_name.dart';

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
    return Container(
      margin: EdgeInsets.only(
        bottom: context.respDim(CcPaddingParams.SPACE_MD),
      ),
      child: _buildMainCard(context),
    );
  }

  BaseAssetListItem _buildMainCard(BuildContext context) {
    return BaseAssetListItem(
      isEditMode: isEditMode,
      canDelete: canDelete,
      onEdit: onEdit,
      onDelete: onDelete,
      dragHandle: dragHandle,
      header: _buildHeader(context),
      stats: [
        AssetStatItem(
          label: el.tr(CcLocaleKeys.report_investment_returned),
          value: returned,
          color: PrjColors.success,
          icon: const Icon(Icons.auto_graph_rounded),
        ),
        const CcSpaceXS(),
        Divider(
          color: context.ccColorScheme.onSurface.withOpacity(0.06),
          height: 1,
        ),
        const CcSpaceXS(),
        AssetStatItem(
          label: el.tr(CcLocaleKeys.report_investment_contributed),
          value: contributed,
          color: context.ccColorScheme.onSurfaceVariant,
          icon: const Icon(Icons.eco),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Row(
      children: [
        Container(
          width: context.respDim(30),
          height: context.respDim(30),
          decoration: BoxDecoration(
            color: PrjColors.success.withOpacity(0.12),
            borderRadius: context.brMd,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: CcGlassyGradientIcon()),
              CcIconToken(iconDataFromCode(wallet.iconCode), size: 14),
            ],
          ),
        ),
        const CcSpaceXS(),
        Expanded(
          child: CcText(
            wallet.displayName(context),
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
