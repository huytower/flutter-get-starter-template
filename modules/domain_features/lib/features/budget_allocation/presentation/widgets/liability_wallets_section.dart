import 'package:cc_sdk_ui/export_cc_sdk_ui.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:flutter/material.dart';

import '../../../loan/domain/entities/loan_balance_entity.dart';
import '../../../loan/presentation/widgets/loan_list_card.dart';

class LiabilityWalletsSection extends StatelessWidget {
  const LiabilityWalletsSection({
    required this.balances,
    required this.onSeeAll,
    super.key,
  });

  final List<LoanBalanceEntity> balances;
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
              if (balances.isNotEmpty)
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
          ),
        ),
        if (balances.isEmpty)
          _buildEmptyState(context)
        else
          _buildVerticalList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CcSymmetricPadding(
      horizontal: CcPaddingParams.SPACE_LG,
      vertical: 12,
      child: CcText(
        el.tr(CcLocaleKeys.loan_empty_state),
        textAlign: TextAlign.center,
        textStyle: context.ccTextTheme.bodyLarge?.copyWith(
          color: context.ccColorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildVerticalList(BuildContext context) {
    // Show only first 3 loans in preview
    final previewBalances = balances.take(3).toList();

    return CcSymmetricPadding(
      horizontal: CcPaddingParams.SPACE_LG,
      child: Column(
        children: previewBalances.map((b) => LoanListCard(balance: b)).toList(),
      ),
    );
  }
}
