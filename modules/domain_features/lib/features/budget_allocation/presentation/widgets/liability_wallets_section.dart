import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../liability/domain/entities/liability_balance_entity.dart';
import 'liability_wallet_preview_card.dart';

class LiabilityWalletsSection extends StatelessWidget {
  const LiabilityWalletsSection({
    required this.balances,
    required this.onAddLoan,
    required this.onMore,
    required this.onSeeAll,
    super.key,
  });

  final List<LiabilityBalanceEntity> balances;
  final VoidCallback onAddLoan;
  final ValueChanged<LiabilityBalanceEntity> onMore;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CcPadding(
          CcSectionHeader(
            title: el.tr(CcLocaleKeys.liability_list_title),
            icon: Icons.warning_amber_outlined,
            actions: [
              CcInkWell(
                onTap: onAddLoan,
                child: const CcIconToken(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                ),
              ),
              if (balances.isNotEmpty) ...[
                const CcSpaceSM(),
                CcInkWell(
                  onTap: onSeeAll,
                  child: CcText(
                    el.tr(CcLocaleKeys.wallet_see_all),
                    textStyle: context.ccTextTheme.titleSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: CcTypographyParams.semiBold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          CcPaddingParams.SPACE_SM,
          CcPaddingParams.SPACE_LG,
          CcPaddingParams.SPACE_MD,
          CcPaddingParams.SPACE_LG,
        ),
        if (balances.isEmpty)
          _buildEmptyState(context)
        else
          _buildHorizontalList(context, balances),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.SPACE_LG,
      vertical: 12,
      child: CcText(
        el.tr(CcLocaleKeys.liability_empty_state),
        textAlign: TextAlign.center,
        textStyle: context.ccTextTheme.bodySmall?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant.withAlpha(50),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(
    BuildContext context,
    List<LiabilityBalanceEntity> balances,
  ) {
    return HorizontalFadeScrollView(
      height: context.respDim(95),
      builder: (scrollController) => ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
          vertical: context.respDim(4),
        ),
        itemCount: balances.length,
        itemBuilder: (context, index) {
          final balance = balances[index];
          return Padding(
            padding: EdgeInsets.only(right: context.respDim(12)),
            child: LiabilityWalletPreviewCard(
              balance: balance,
              onMore: () => onMore(balance),
              onTap: onSeeAll,
            ),
          );
        },
      ),
    );
  }
}
