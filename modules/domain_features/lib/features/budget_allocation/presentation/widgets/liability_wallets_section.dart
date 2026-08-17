import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../loan/domain/entities/loan_balance_entity.dart';
import '../../../loan/presentation/widgets/loan_list_card.dart';

class LiabilityWalletsSection extends StatelessWidget {
  const LiabilityWalletsSection({
    required this.balances,
    required this.onAddLoan,
    required this.onMore,
    required this.onSeeAll,
    super.key,
  });

  final List<LoanBalanceEntity> balances;
  final VoidCallback onAddLoan;
  final ValueChanged<LoanBalanceEntity> onMore;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = context.ccColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_LG),
            context.respPadding(CcPaddingParams.SPACE_MD),
            context.respPadding(CcPaddingParams.SPACE_SM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CcText(
                el.tr(CcLocaleKeys.loan_list_title),
                textStyle: context.ccTextTheme.titleSmall?.copyWith(
                  fontWeight: CcTypographyParams.bold,
                  color: scheme.onBackground,
                ),
              ),
              Row(
                children: [
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
            ],
          ),
        ),
        if (balances.isEmpty)
          _buildEmptyState(context)
        else
          _buildHorizontalList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.SPACE_LG,
      vertical: 12,
      child: Column(
        children: [
          CcText(
            el.tr(CcLocaleKeys.loan_empty_state),
            textAlign: TextAlign.center,
            textStyle: context.ccTextTheme.bodyLarge?.copyWith(
              color: context.ccColorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: CcInkWell(
              onTap: onAddLoan,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.respPadding(CcPaddingParams.SPACE_LG),
                  vertical: context.respPadding(CcPaddingParams.SPACE_MD),
                ),
                decoration: BoxDecoration(
                  color: context.ccColorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.ccColorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: context.ccColorScheme.primary,
                      size: context.respIconSize(baseSize: 20),
                    ),
                    const SizedBox(width: 8),
                    CcText(
                      el.tr(CcLocaleKeys.common_add),
                      textStyle: context.ccTextTheme.labelMedium?.copyWith(
                        color: context.ccColorScheme.primary,
                        fontWeight: CcTypographyParams.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context) {
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
            child: LoanListCard(
              balance: balance,
              onTap: () => onMore(balance),
            ),
          );
        },
      ),
    );
  }
}
